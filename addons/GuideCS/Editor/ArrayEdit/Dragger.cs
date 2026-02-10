using Godot;
using System;

namespace Guide;

[Tool]
public partial class Dragger : Button {
    public GodotObject _ParentArray;
    public int _Index;

    public override Variant _GetDragData(Vector2 atPosition) {
        return new Godot.Collections.Dictionary
        {
            { "parent_array", _ParentArray },
            { "index", _Index }
        };
    }
}
