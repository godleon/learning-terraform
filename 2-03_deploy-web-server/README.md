可透過以下指令執行：

> terraform plan -var "server_port=8080"

參數部份可以透過 `-var` or `export TF_VAR_[var name]` 的方式從 CLI 中指定


顯示 output：

> terraform output public_ip