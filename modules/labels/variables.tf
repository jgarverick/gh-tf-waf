# Variables file for the labels module

variable "repository" {
  description = "The name of the repository to which labels will be added"
  type        = string
}

variable "labels" {
  description = "A map of label names to their corresponding colors"
  type        = map(string)
}
