using Godot;

namespace Guide;

public partial class EditorUtils : RefCounted {
	public static void Clear(Node node) {
		if (!IsInstanceValid(node)) return;
		foreach (var child in node.GetChildren()) {
			node.RemoveChild(child);
			child.QueueFree();
		}
	}

	public static Resource DuplicateIfInline(Resource resource) {
		if (IsInline(resource)) return resource.Duplicate();
		return resource;
	}

	public static bool IsInline(Resource resource) {
		if (resource == null) return false;
		return resource.ResourcePath.Contains("::") || string.IsNullOrEmpty(resource.ResourcePath);
	}

	public static bool IsNodeInEditedScene(Node node) {
		if (!Engine.IsEditorHint()) return false;
		if (!IsInstanceValid(node)) return false;

		var editorInterface = Engine.GetSingleton("EditorInterface");
		if (editorInterface == null) return false;

		var sceneRoot = EditorInterface.Singleton.GetEditedSceneRoot();
		if (!IsInstanceValid(sceneRoot)) return false;

		return node == sceneRoot || sceneRoot.IsAncestorOf(node);
	}
}
