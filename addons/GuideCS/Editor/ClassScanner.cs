using System.Collections.Generic;
using Godot;

namespace Guide;

[Tool]
public partial class ClassScanner : RefCounted {
	private static bool _dirty = true;
	private static Dictionary<StringName, ScriptInfo> _scriptLut = new();

	static ClassScanner() {
		if (Engine.IsEditorHint()) {
			var filesystem = EditorInterface.Singleton.GetResourceFilesystem();
			filesystem.ScriptClassesUpdated += () => _dirty = true;
		}
	}

	public static Dictionary<StringName, Script> FindInheritors(StringName clazzName) {
		var result = new Dictionary<StringName, Script>();

		if (Engine.IsEditorHint()) {
			var filesystem = EditorInterface.Singleton.GetResourceFilesystem();
			var root = filesystem.GetFilesystem();

			if (_dirty) {
				_scriptLut.Clear();
				_Scan(root);
				_dirty = false;
			}
		}

		var openSet = new GUIDESet();
		var closedSet = new GUIDESet();

		openSet.Add(clazzName);

		while (!openSet.IsEmpty()) {
			var next = openSet.Pull().AsStringName();
			closedSet.Add(next);

			if (!_scriptLut.ContainsKey(next)) continue;

			foreach (var item in _scriptLut.Values) {
				if (item.Extendz == next) {
					result[item.ClazzName] = item.ClazzScript;
					if (!closedSet.Has(item.ClazzName)) {
						openSet.Add(item.ClazzName);
					}
				}
			}
		}

		return result;
	}

	private static void _Scan(EditorFileSystemDirectory folder) {
		for (int i = 0; i < folder.GetFileCount(); i++) {
			var scriptClazz = folder.GetFileScriptClassName(i);
			if (!string.IsNullOrEmpty(scriptClazz)) {
				if (!_scriptLut.TryGetValue(scriptClazz, out var info)) {
					info = new ScriptInfo {
						ClazzName = scriptClazz,
						ClazzScript = GD.Load<Script>(folder.GetFilePath(i))
					};
					_scriptLut[scriptClazz] = info;
				}
				info.Extendz = folder.GetFileScriptClassExtends(i);
			}
		}

		for (int i = 0; i < folder.GetSubdirCount(); i++) {
			_Scan(folder.GetSubdir(i));
		}
	}

	private class ScriptInfo {
		public StringName ClazzName;
		public StringName Extendz;
		public Script ClazzScript;

		public override string ToString() => $"{ClazzName}:{Extendz}";
	}
}
