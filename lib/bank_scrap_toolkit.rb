require "bank_scrap_toolkit/version"

module BankScrapToolkit
  autoload :CLI, 'bank_scrap_toolkit/cli'
  autoload :Mitmproxy, 'bank_scrap_toolkit/mitmproxy'
  autoload :Mitmdump, 'bank_scrap_toolkit/mitmdump'
  autoload :Flow, 'bank_scrap_toolkit/flow'
end
