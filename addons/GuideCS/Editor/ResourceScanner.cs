using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Guide;

[Tool]
public partial class ResourceScanner : RefCounted {
    private static readonly RegEx _regex = new();

    static ResourceScanner() {
        _regex.Compile("gd_resource.*?script_class=\"([^\"]+)\"");
    }

    public static string[] FindResourcesOfType(StringName typeName) {
        var result = new List<string>();
        var inheritors = new List<string> { typeName };
        inheritors.AddRange(ClassScanner.FindInheritors(typeName).Keys.Select(k => k.ToString()));

        if (Engine.IsEditorHint()) {
            var filesystem = EditorInterface.Singleton.GetResourceFilesystem();
            _FindResourcesOfTypeIn(filesystem.GetFilesystem(), inheritors, result);
        }

        return result.ToArray();
    }

    private static void _FindResourcesOfTypeIn(EditorFileSystemDirectory directory, List<string> inheritors, List<string> result) {
        for (int i = 0; i < directory.GetSubdirCount(); i++) {
            _FindResourcesOfTypeIn(directory.GetSubdir(i), inheritors, result);
        }

        for (int i = 0; i < directory.GetFileCount(); i++) {
            string path = directory.GetFilePath(i);
            string engineType = directory.GetFileType(i);
            string actualType = engineType;

            if (engineType == "Resource") {
                string resourceScriptClass = _GetResourceScriptClass(path);
                if (!string.IsNullOrEmpty(resourceScriptClass)) {
                    actualType = resourceScriptClass;
                }
            }

            if (inheritors.Contains(actualType)) {
                result.Add(path);
            }
        }
    }


    private static string _GetResourceScriptClass(string path) {
        if (!path.EndsWith(".tres")) return "";

        string content = FileAccess.GetFileAsString(path);
        var match = _regex.Search(content);
        if (match == null) return "";

        return match.GetString(1);
    }
}
