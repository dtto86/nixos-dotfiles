-- yamlls + SchemaStore, ported unchanged from the previous config's
-- lua/plugins/yamlls.lua: adds the AWS SAM/CloudFormation schema and short-form
-- intrinsic-function customTags (!Ref, !Sub, !GetAtt, ...) on top of SchemaStore's
-- catalog. See lsp-json.lua for the equivalent on JSON-format CFN templates.
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
        yamlls = {
          capabilities = {
            textDocument = {
              foldingRange = { dynamicRegistration = false, lineFoldingOnly = true },
            },
          },
          before_init = function(_, new_config)
            new_config.settings = new_config.settings or {}
            new_config.settings.yaml = new_config.settings.yaml or {}
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas({
                replace = {
                  ["AWS CloudFormation Serverless Application Model (SAM)"] = {
                    name = "AWS CloudFormation Serverless Application Model (SAM)",
                    description = "The AWS Serverless Application Model (AWS SAM) extends AWS CloudFormation to provide a simplified way of defining the Amazon API Gateway APIs, AWS Lambda functions, and Amazon DynamoDB tables needed by your serverless application",
                    fileMatch = {
                      "template.yaml",
                      "template.cfn.yaml",
                      "serverless.template",
                      "*.sam.json",
                      "*.sam.yml",
                      "*.sam.yaml",
                      "sam.json",
                      "sam.yml",
                      "sam.yaml",
                    },
                    url = "https://raw.githubusercontent.com/aws/serverless-application-model/main/samtranslator/schema/schema.json",
                  },
                },
              })
            )
            new_config.settings.yaml.customTags = {
              "!fn",
              "!And",
              "!If",
              "!Not",
              "!Equals",
              "!Or",
              "!FindInMap sequence",
              "!Base64",
              "!Cidr",
              "!Ref",
              "!Ref Scalar",
              "!Sub",
              "!GetAtt",
              "!GetAZs",
              "!ImportValue",
              "!Select",
              "!Split",
              "!Join sequence",
            }
          end,
          settings = {
            redhat = { telemetry = { enabled = false } },
            yaml = {
              keyOrdering = false,
              format = { enable = true },
              validate = true,
              schemaStore = { enable = false, url = "" },
              hover = true,
              completion = true,
              schemas = {},
              schemaValidation = true,
            },
          },
        },
      },
    },
  },
}
