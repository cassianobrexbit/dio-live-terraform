# Simplifique o Gerenciamento de Infraestrutura com Terraform na AWS

## Configurações iniciais

- Instalação do Terraform:
  - https://www.terraform.io/downloads.html
  
- Criar conta na AWS
  - https://portal.aws.amazon.com/billing/signup
  
- Criar um usuário no AWS IAM
  - https://docs.aws.amazon.com/rekognition/latest/dg/setting-up.html
  
## Desenvolvendo a aplicação

### Passos iniciais
  
- Clonar o repositório
- Criar um bucket no Amazon S3
- Configurar variáveis
  - Subistiuir {aws_account_id} pelo ID da sua conta AWS
  - Substituir {table_name} pelo nome da sua tabela do DynamoDB
  - Substituir {s3_bucket_name} pelo nome do seu bucket S3 criado anteriormente
  
- Compactar as funções lambda em um arquivo .zip
- Upload das funções compactadas para o bucket S3 criado
  
### Comandos no Terraform

- Iniciar o Terraform e baixar módulos: 
```terraform init```
- Deploy da infraestrutura na AWS:
```terraform apply -auto-approve```
