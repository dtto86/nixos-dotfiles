-- jsonls + SchemaStore, ported from LazyVim's lang.json extra, extended with the same
-- AWS SAM/CloudFormation schema added to yamlls in lsp-yaml.lua so JSON-format
-- templates get validation/completion too.
return {
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        jsonls = {
          before_init = function(_, new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
            table.insert(new_config.settings.json.schemas, {
              name = "AWS CloudFormation Serverless Application Model (SAM)",
              description = "The AWS Serverless Application Model (AWS SAM) extends AWS CloudFormation to provide a simplified way of defining the Amazon API Gateway APIs, AWS Lambda functions, and Amazon DynamoDB tables needed by your serverless application",
              fileMatch = { "template.json", "template.cfn.json", "*.sam.json", "sam.json" },
              url = "https://raw.githubusercontent.com/aws/serverless-application-model/main/samtranslator/schema/schema.json",
            })
          end,
          settings = {
            json = {
              format = { enable = true },
              validate = { enable = true },
            },
          },
        },
      },
    },
  },
}
