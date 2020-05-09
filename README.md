# learning-terraform
Example codes for learning Terraform


準備 GCP 帳號需要注意事項
======================

要設定 terraform 用帳號，需要進行以下幾個部份：

1. [建立 Service Account](https://console.cloud.google.com/iam-admin/serviceaccounts) (GCP console -> `IAM & Admin` -> `Service Accounts`)

2. 新增一個 Terraform(or robot) 專用的 service account

3. 到 [`IAM`](https://console.cloud.google.com/iam-admin/iam?authuser=2&orgonly=true&project=axial-camp-269920&supportedpurview=organizationId) 頁面，會出現上一個步驟建立的 service account，點選編輯以新增權限

4. 將所需要的 `Role`(權限是以 Role 的方式給入)加入到 service account 中，點選 Save 即可

5. 回到 `Service Accounts` 頁面，點選 service account 的 `Actions` 欄位，選擇 `Create Key`，key type 選擇 `json` 並下載


準備 AWS 帳號需要注意事項
=================

- 不要用 root user，root user 只是拿來建立其他受限的帳號用，實際使用時應該使用受限的帳號

- 從 `IAM` -> `Users` -> `Create New Users` 建立新的使用者，新增時勾選 **Access type** 中的 `Programmatic access` 選項；接著分別給入 Group / Permissions Boundary / tags 等資訊後，就可以順利建立使用者並取得 access key & secret key

- 建立 User 後，還要跟 IAM policy 作結合，這樣才會有權限：此外也有一些 AWS 預先定義好的權限組(a.k.a. Managed Policies)可使用

- 可建立一個 Group，把所有需要的權限與 Group 綁定後，把 user 加進來

Terraform Lab 需要以下權限：

- AmazonEC2FullAccess

- AmazonS3FullAccess

- AmazonDynamoDBFullAccess

- AmazonRDSFullAccess

- CloudWatchFullAccess

- IAMFullAccess

## 讓程式可以使用正確的權限

```bash
$ export AWS_ACCESS_KEY_ID=[YOUR_ACCESS_KEY]
$ export AWS_SECRET_ACCESS_KEY=[YOR_SECRET_ACCESS_KEY]
```

> 也可以把認證資訊放在 `$HOME/.aws/credentials`


開發時筆記
========

## Auto Scaling Group

aws_launch_configuration -> lifecycle -> create_before_destroy 的設定

由於此資源已經被其他資源給引用，因此變更時會遭到刪除，但因為引用關係而刪除不了
透過變更 resource lifecycle 的方式可以解決此問題

- `subnet_ids` 屬性是必備的，ASG 才會知道 EC2 instance 應該使用的網路設定從哪來