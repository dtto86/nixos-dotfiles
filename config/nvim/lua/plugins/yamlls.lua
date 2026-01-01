return {
  -- yaml schema support
  {
    "b0o/SchemaStore.nvim",
    lazy = true,
    version = false, -- last release is way too old
  },

  -- correctly setup lspconfig
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- make sure mason installs the server
      servers = {
        yamlls = {
          -- Have to add this for yamlls to understand that we support line folding
          capabilities = {
            textDocument = {
              foldingRange = {
                dynamicRegistration = false,
                lineFoldingOnly = true,
              },
            },
          },
          -- lazy-load schemastore when needed
          before_init = function(_, new_config)
            print("in on_new_config for yamlls")
            new_config.settings.yaml.schemas = vim.tbl_deep_extend(
              "force",
              new_config.settings.yaml.schemas or {},
              require("schemastore").yaml.schemas {
                replace = {
                  -- ['AWS CloudFormation'] = {
                  --   description = "AWS CloudFormation provides a common language for you to describe and provision all the infrastructure resources in your cloud environment",
                  --   name = "AWS CloudFormation",
                  --   url = "https://raw.githubusercontent.com/awslabs/goformation/master/schema/cloudformation.schema.json",
                  --   fileMatch = { "cloudformation.json", "cloudformation.yaml", "cloudformation.yml", "*.cf.json", "*.cf.yaml", "*.cf.yml", "*.cfn.yaml" },
                  -- }
                  ['AWS CloudFormation Serverless Application Model (SAM)'] = {
                    name = "AWS CloudFormation Serverless Application Model (SAM)",
                    description = "The AWS Serverless Application Model (AWS SAM, previously known as Project Flourish) extends AWS CloudFormation to provide a simplified way of defining the Amazon API Gateway APIs, AWS Lambda functions, and Amazon DynamoDB tables needed by your serverless application",
                    fileMatch = { "template.yaml", "template.cfn.yaml", "serverless.template", "*.sam.json", "*.sam.yml", "*.sam.yaml", "sam.json", "sam.yml", "sam.yaml" },
                    url = "https://raw.githubusercontent.com/aws/serverless-application-model/main/samtranslator/schema/schema.json",
                  }
                }
              }
            )
            new_config.settings.yaml.customTags = {
              -- "!And scalar", "!And sequence",
              -- "!If scalar", "!If sequence",
              -- "!Not scalar", "!Not sequence",
              -- "!Equals scalar", "!Equals sequence",
              -- "!Or scalar", "!Or sequence",
              -- "!FindInMap scalar", "!FindInMap sequence",
              -- "!Base64 scalar", "!Cidr scalar",
              -- "!Ref scalar", "!Ref sequence",
              -- "!Sub scalar", "!Sub sequence",
              -- "!GetAtt scalar", "!GetAtt sequence",
              -- "!GetAZs scalar",
              -- "!ImportValue scalar", "!ImportValue sequence",
              -- "!Select scalar", "!Select sequence",
              -- "!Split scalar", "!Split sequence",
              -- "!Join scalar", "!Join sequence",
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
              format = {
                enable = true,
              },
              validate = true,
              schemaStore = {
                -- Must disable built-in schemaStore support to use
                -- schemas from SchemaStore.nvim plugin
                enable = false,
                -- Avoid TypeError: Cannot read properties of undefined (reading 'length')
                url = "",
              },
              hover = true,
              completion = true,
              schemas = {},
              schemaValidation = true, -- <- add false if you want to silence schema errors
            },
          },
        },
      },
      setup = {
        yamlls = function()
          -- Neovim < 0.10 does not have dynamic registration for formatting
          if vim.fn.has("nvim-0.10") == 0 then
            LazyVim.lsp.on_attach(function(client, _)
              client.server_capabilities.documentFormattingProvider = true
            end, "yamlls")
          end
        end,
      },
    },
  },
}
