output "arn" {
  description = "ARN from Queue"
  value       = aws_sqs_queue.queue.arn
}

output "id" {
  description = "ID from Queue"
  value       = aws_sqs_queue.queue.id
}

output "name" {
  description = "NAME from Queue"
  value       = aws_sqs_queue.queue.name
}