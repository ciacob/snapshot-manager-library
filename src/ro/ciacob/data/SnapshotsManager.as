package ro.ciacob.data {
	
	import ro.ciacob.utils.Time;
	
	public class SnapshotsManager {
		
		/**
		 * @param	storageSize
		 * 			The maximum number of snapsots to hold in memory. Oldest snapshot get deleted as new snapshots come in,
		 * 			to enforce this limit.
		 */
		public function SnapshotsManager (storageSize:uint) {
			_storageSize = storageSize;
		}
		
		private var _storageSize : uint;
		private var _currentSnapshot : Snapshot = null;
		private const _undoSnapshots : Array = [];
		private const _redoSnapshots : Array = [];
		
		public function get canUndo () : Boolean {
			return _undoSnapshots.length > 0;
		}
		
		public function get canRedo () : Boolean {
			return _redoSnapshots.length > 0;
		}
		
		public function getNextUndoSnapshot () : Snapshot {
			if (canUndo) {
				var snapshot : Snapshot = _undoSnapshots.pop() as Snapshot;
				if (_currentSnapshot) {
					_redoSnapshots.unshift (_currentSnapshot);
				}
				_currentSnapshot = snapshot;
				// _printStacks();
				return _currentSnapshot;
			}
			return null;
		}
		
		public function getNextRedoSnapshot () : Snapshot {
			if (canRedo) {
				var snapshot : Snapshot = _redoSnapshots.shift() as Snapshot;
				if (_currentSnapshot) {
					_undoSnapshots.push(_currentSnapshot);
				}
				_currentSnapshot = snapshot;
				// _printStacks();
				return _currentSnapshot;
			}
			return null;
		}
		
		public function get undoLabel () : String {
			if (canUndo) {
				return (_undoSnapshots[_undoSnapshots.length - 1] as Snapshot).description;
			}
			return null;
		}
		
		public function get redoLabel () : String {
			if (canRedo) {
				return (_redoSnapshots[0] as Snapshot).description;
			}
			return null;
		}
		
		public function takeSnapshot (source : Object, description : String = null, metadata : Object = null) : void {
			if (!description) {
				description = SnapshotKeys.DEFAULT_DESCRIPTION.replace('%s', Time.timestamp);
			}
			var snapshot : Snapshot = new Snapshot (source, description, metadata);
			if (canRedo) {
				deleteRedoHistory();
			}
			
			if (_currentSnapshot) {
				if (_isUndoStackFull()) {
					_trimUndoStack();
				}
				_undoSnapshots.push(_currentSnapshot);
			}
			_currentSnapshot = snapshot;
			// _printStacks();
		}
		
		public function reset () : void {
			deleteUndoHistory();
			deleteRedoHistory();
			_currentSnapshot = null;
		}
		
		public function deleteRedoHistory () : void {
			_redoSnapshots.length = 0;
		}
		
		public function deleteUndoHistory () : void {
			_undoSnapshots.length = 0;
		}
		
		private function _isUndoStackFull () : Boolean {
			return _undoSnapshots.length >= _storageSize;
		}
		
		private function _trimUndoStack () : void {
			_undoSnapshots.splice (0, _undoSnapshots.length - _storageSize + 1);
		}

		// [DEBUG]
		//	private function _printStacks () : void {
		//		var i : int;
		//		trace ('--------------------------')
		//		trace ('UNDO SNAPSHOTS');
		//		for (i = 0; i < _undoSnapshots.length; i++) {
		//			trace (i, (_undoSnapshots[i] as Snapshot).description);
		//		}
		//		trace ('\n');
		//		trace ('CURRENT SNAPSHOT');
		//		trace (_currentSnapshot? _currentSnapshot.description : 'NULL');
		//		trace ('\n');
		//		trace ('REDO SNAPSHOTS');
		//		for (i = 0; i < _redoSnapshots.length; i++) {
		//			trace (i, (_redoSnapshots[i] as Snapshot).description);
		//		}
		//	}
		// [/DEBUG]
		
	}
}

