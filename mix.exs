defmodule EEx.Mixfile do
  use Mix.Project

  def project do
   [app: :wdex, version: "0.1", deps: deps]
  end

  defp deps do
    [
     { :genx, %r(.*), git: "https://github.com/yrashk/genx.git"},
     {:jsx, %r(.*), git: "https://github.com/talentdeficit/jsx.git"},
     {:lhttpc, %r(.*), git: "https://github.com/esl/lhttpc.git"},

     {:mimetypes, %r(.*), git: "https://github.com/spawngrid/mimetypes.git"},
     {:edown, %r(.*), git: "https://github.com/esl/edown.git"},
     {:hackney, %r(.*), git: "https://github.com/benoitc/hackney.git"}
    ]
  end
end