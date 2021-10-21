package ro.ciacob.data {
	import flash.net.registerClassAlias;
	import flash.utils.ByteArray;
	import flash.utils.CompressionAlgorithm;
	
	import avmplus.getQualifiedClassName;

	public class Snapshot {
		
		private var _bytes : ByteArray = new ByteArray();
		private var _description : String;
		private var _metadata : Object;

		/**
		 * Stores a snapshot and provides means to access its individual components
		 * @param	source
		 * 			An Object containing the datamodel you need to store a snapshot of. Note that you don't need to
		 * 			clone the datamodel, this class already does a AMF3 serialization.
		 * 
		 * 			If source is a custom class, its main type is automaticall registered using `registerClassAlias()`.
		 * 			If no other custom types are used inside it, you don't need to do anything. However, if your custom
		 * 			class uses other custom classes as members, all their type must be declared in the `metadata`
		 * 			argument, under the SnapshotKeys.CLASSES_TO_REGISTER key, as a Vector of type `Class`.
		 * 
		 * 			Example:
		 * 			var myCustomTypes : Vector.<Class> = new Vector.<Class>;
		 * 			myCustomTypes.push (MyCustomClass, MyOtherCustomClass); // etc.
		 * 			var myMetadata : Object = {};
		 * 			myMetadata[SnapshotKeys.CLASSES_TO_REGISTER] = myCustomTypes; // you can also add your own keys to metadata if need be
		 * 			var sm : SnapShotManager = new SnapShotManager (10); // assuming a storage size of `10`, not relevant;
		 * 			sm.takeSnapshot (mySource, myDescription, myMetadata); // assuming that `mySource` and `myDescription` were already defined elsewhere.
		 * 
		 * @param	description
		 * 			A string describing this snapshot. If not given will default to a text including the timestamp of the moment the snapshot was taken.
		 * 
		 * @param	metadata
		 * 			An arbitrary Value Object containing data that is connex to the source. Does not get serialized in AMF3, therefore
		 * 			you should NOT use `metadata` to store your datamodel, as thid will create a reference to it, not a copy/clone
		 * 			(which would make taking a snapshot futile).
		 */
		public function Snapshot  (source : Object, description : String, metadata : Object) {
			_description = description;
			
			// Prepare for source Object serialization
			if (metadata) {
				
				// Register any required additional classes prior serialization
				var classesToRegister : Vector.<Class> = metadata[SnapshotKeys.CLASSES_TO_REGISTER] as Vector.<Class>;
				if (classesToRegister) {
					for each (var classToRegister : Class in classesToRegister) {
						registerClassAlias (getQualifiedClassName(classToRegister), classToRegister);
					}
				}
				_metadata = metadata;
			}
			
			// Always register the class of the source Object prior serialization
			var srcClass : Class = source.constructor;
			var srcAlias : String = getQualifiedClassName(srcClass);
			registerClassAlias(srcAlias, srcClass);
			
			// Serialize and store source Object
			_bytes.writeObject(source);
		}
		
		public function get description () : String {
			return _description;
		}
		
		public function get metadata () : Object {
			return _metadata;
		}
		
		public function get source () : Object {
			_bytes.position = 0;
			var clone:Object = _bytes.readObject();
			return clone;
		}
		
	}
}