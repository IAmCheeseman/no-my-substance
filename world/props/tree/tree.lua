local tree = {
    sprite = Sprite.new("world/props/tree/tree.png", 1, 0)
}

Objects.create_type_from("Tree", "SwayingProp", tree)