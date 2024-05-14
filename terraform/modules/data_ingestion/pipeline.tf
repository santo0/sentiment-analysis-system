resource "aws_kinesis_stream" "kinesis_stream" {
    name = "tweet-kinesis-stream"
    shard_count =  variable.shard_count
    shard_level_metrics = varialbe.shard_level_metrics
}