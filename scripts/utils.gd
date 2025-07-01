class_name Utils


static func assert_authority(node: Node) -> void:
  assert(node.is_multiplayer_authority(), "Node %s is not the authority here." % node.get_path())


static func assert_server(node: Node) -> void:
  assert(node.multiplayer.is_server(), "Node %s is not the server here." % node.get_path())