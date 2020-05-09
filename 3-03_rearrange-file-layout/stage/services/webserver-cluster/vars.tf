# 支援資料型態：tring, number, bool, list, map, set, object, tuple, and any
variable "server_port" {
    description = "The port the server will use for HTTP requests"
    type        = number
    default     = 8080
}