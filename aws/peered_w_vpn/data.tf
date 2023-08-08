data "aws_vpc_peering_connection" "hub_dmz" {
  depends_on  = [aws_vpc_peering_connection.hub_dmz]
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.dmz.id
}

data "aws_vpc_peering_connection" "hub_app" {
  depends_on  = [aws_vpc_peering_connection.hub_app]
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.app.id
}

data "aws_vpc_peering_connection" "hub_db" {
  depends_on  = [aws_vpc_peering_connection.hub_db]
  vpc_id      = aws_vpc.hub.id
  peer_vpc_id = aws_vpc.db.id
}