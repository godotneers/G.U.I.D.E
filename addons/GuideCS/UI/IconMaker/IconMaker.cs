using System;
using System.Collections.Generic;
using System.Threading.Tasks;
using Godot;

namespace Guide;

[Tool]
public partial class IconMaker : Node {
	private const string CacheDir = "user://_guide_cache";

	private SubViewport _subViewport;
	private Node2D _root;
	private Sprite2D _sceneHolder;

	private List<Job> _pendingRequests = new();
	private Job _currentRequest = null;
	private bool _fetchImage = false;

	public override void _Ready() {
		ProcessMode = ProcessModeEnum.Always;
		_subViewport = GetNode<SubViewport>("%SubViewport");
		_root = GetNode<Node2D>("%Root");
		_sceneHolder = GetNode<Sprite2D>("%SceneHolder");

		if (_pendingRequests.Count == 0) SetProcess(false);
	}

	public void ClearCache() {
		using var dir = DirAccess.Open(CacheDir);
		if (dir != null) {
			foreach (var file in dir.GetFiles()) {
				dir.Remove(file);
			}
		}
	}

	public async Task<Texture2D> MakeIcon(GUIDEInput input, GUIDEIconRenderer renderer, int heightPx, GUIDEInputFormattingOptions options) {
		DirAccess.MakeDirRecursiveAbsolute(CacheDir);
		string cacheKey = (heightPx.ToString() + renderer.CacheKey(input, options)).Sha256Text();
		string cachePath = $"{CacheDir}/{cacheKey}.res";

		if (ResourceLoader.Exists(cachePath)) {
			return GD.Load<Texture2D>(cachePath);
		}

		var job = new Job {
			Height = heightPx,
			Input = input,
			Options = options,
			Renderer = renderer,
			Tcs = new TaskCompletionSource<Image>()
		};

		_pendingRequests.Add(job);
		SetProcess(true);

		var resultImage = await job.Tcs.Task;

		var imageTexture = ImageTexture.CreateFromImage(resultImage);
		ResourceSaver.Save(imageTexture, cachePath);
		imageTexture.TakeOverPath(cachePath);

		return imageTexture;
	}

	public override async void _Process(double delta) {
		if (_currentRequest == null && _pendingRequests.Count == 0) {
			SetProcess(false);
			return;
		}

		if (_currentRequest == null) {
			_currentRequest = _pendingRequests[0];
			_pendingRequests.RemoveAt(0);

			var renderer = _currentRequest.Renderer;
			_root.AddChild(renderer);

			renderer.Render(_currentRequest.Input, _currentRequest.Options);
			await ToSignal(GetTree(), SceneTree.SignalName.ProcessFrame);

			var actualSize = renderer.GetRect().Size;
			float scale = (float)_currentRequest.Height / actualSize.Y;
			_root.Scale = Vector2.One * scale;
			_subViewport.Size = (Vector2I)(actualSize * scale);

			_subViewport.RenderTargetUpdateMode = SubViewport.UpdateMode.Always;

			await ToSignal(GetTree(), SceneTree.SignalName.ProcessFrame);
			await ToSignal(GetTree(), SceneTree.SignalName.ProcessFrame);
			await ToSignal(GetTree(), SceneTree.SignalName.ProcessFrame);

			_fetchImage = true;
			return;
		}

		if (_fetchImage) {
			var image = _sceneHolder.Texture.GetImage();
			_currentRequest.Tcs.SetResult(image);

			_root.RemoveChild(_root.GetChild(0));
			_subViewport.RenderTargetUpdateMode = SubViewport.UpdateMode.Disabled;
			_fetchImage = false;
			_currentRequest = null;
		}
	}

	private class Job {
		public int Height;
		public GUIDEInput Input;
		public GUIDEIconRenderer Renderer;
		public GUIDEInputFormattingOptions Options;
		public TaskCompletionSource<Image> Tcs;
	}
}
