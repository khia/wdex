defmodule WDeX.Rest do
  defmodule API do
    defmacro __using__(_) do
      Module.add_attribute __CALLER__.module,
        :before_compile, {__MODULE__, :__before_compile__}
      quote do: unquote(prologue(__CALLER__))
    end
    def __before_compile__(module) do
      commands = Module.read_attribute module, :commands
      Module.delete_attribute module, :commands

      types = Module.read_attribute module, :types
      Module.delete_attribute module, :types

      mappings = Module.read_attribute module, :mappings
      Module.delete_attribute module, :mappings

      records = Module.read_attribute module, :records
      Module.delete_attribute module, :records

      quoted = WDeX.Rest.Codegen.define(commands, types, mappings, records)
      #Code.eval_quoted quoted
      Module.eval_quoted module, quoted, []
    end
    def prologue(caller) do
       quote do
         import WDeX.Rest.DSL
         Module.register_attribute unquote(caller.module),
           :commands, persist: true, accumulate: true
         Module.register_attribute unquote(caller.module),
           :types, persist: true, accumulate: true
         Module.register_attribute unquote(caller.module),
           :mappings, persist: true, accumulate: true
         Module.register_attribute unquote(caller.module),
           :records, persist: true, accumulate: true
         def start() do
           WDeX.Rest.Client.start
         end
       end
    end
  end

  defmodule Codegen do
    def define(commands, types, mappings, records) do
      quoted = lc spec inlist commands, do: command(spec)
      # dump(commands, types, mappings, records, quoted)
      quoted
    end

    defp dump(commands, types, mappings, records, quoted) do
      IO.puts "commands: #{inspect commands}"
      IO.puts "types: #{inspect types}"
      IO.puts "mappings: #{inspect mappings}"
      IO.puts "records: #{inspect records}"
      IO.puts Macro.to_binary quoted
    end

    def command({name, returns, args, options, method, path, path_args, doc}) do
      {_defaults, types} = WDeX.Rest.DSL.split_spec(args)
      args = lc {id, _} inlist types, do: id
      path_replace =
        lc {id, _, _} = var inlist path_args do
           quote do
             path = String.replace path,
                      unquote(Macro.to_binary(id)), unquote(var), global: true
           end
        end
      quote do
        # TODO: inject specification into doc
        @doc unquote(doc)
        def unquote(name).(base, unquote_splicing(path_args), named // []) do
          # TODO: validate 'args' against 'types'
          # TODO: handle optional args
          path = unquote(path)
          unquote_splicing(path_replace)
          result = apply(WDeX.Rest.Client, unquote(method),
                     [base, path, named])
          IO.puts "result: #{inspect result}"
          # TODO: convert 'result' to 'returns' type if possible
          result
        end
      end
    end
  end

  defmodule Client do
    def start do
      :hackney.start
    end
    def get(base, path, _args) do
      url = join([base, path])
      request(:get, url, <<>>)
    end
    def post(base, path, args) do
      url = join([base, path])
      payload = WDeX.Rest.JSON.encode(args)
      request(:post, url, payload)
    end
    def request(method, url, payload) do
      headers = [{"Content-Type", "application/json"},
                 {"Accept", "application/json"}]
      options = []
      IO.puts "#{inspect method}: #{inspect url} #{inspect payload}"
      {:ok, status, headers, client} =
         :hackney.request(method, url, headers, payload, options)
      IO.puts "status: #{inspect status}"
      {:ok, body, client} = :hackney.body(client)
      returns = WDeX.Rest.JSON.decode body
      {:ok, status, headers, returns, client}
    end
    def join([base, path]) do
      path = case path do
               <<"/", path :: binary>> -> path
               path -> path
             end
      Enum.join([base, path], "/")
    end
  end

  defmodule JSON do
    def encode(data), do: :jsx.to_json(data)
    def decode(data) do
      # selenium-server does a wierd null-byte padding that's confusing jsx
      stripped = case :binary.match(data, <<0>>) do
                   :nomatch -> data
                   {pos, _} ->
                     {h, _t} = :erlang.split_binary(data, pos)
                     h
                 end
      :jsx.to_term(stripped)
    end
  end

  defmodule DSL do
    defmacro exceptions(bindings) do
      lc {name, _value, msg} inlist bindings do
        quote do
          defexception unquote(name), message: unquote(msg)
        end
      end
      lc {name, value, _msg} inlist bindings do
        quote do
          def status(unquote(value)), do: raise apply(:Status, unquote(name), [])
        end
      end
    end

    defmacro spec(method, path, [do: {:__block__, _, [opts]}]) do
      matches = Regex.scan %r/\:[^\/]*/, path

      path_args = lc <<":", t :: binary>> inlist matches do
          {binary_to_atom(t), __CALLER__.line, nil}
        end
      quote do
        @commands {unquote(opts[:name]),
                   unquote(Macro.escape(opts[:returns])),
                   unquote(Macro.escape(opts[:args])),
                   unquote(Macro.escape(opts[:options])),
                   unquote(method), unquote(path),
                   unquote(Macro.escape(path_args)),
                   @doc}
        Module.delete_attribute __MODULE__, :doc
      end
    end

    defmacro type(definition) do
      type(definition, [], __CALLER__)
    end

    defp type({:::, _, [{:|, _, _} = union, type]}, _acc, caller) do
      {id, elements} = type(union, [], caller)
      [type] = type(type, [], caller)
      quote do
        @types {unquote(id), unquote(elements), unquote(type)}
      end
    end
    defp type({:::, _, [{id, _, nil}, {:|, _, _} = union]}, _acc, caller) do
      elements = []
      type = type(union, [], caller)
      quote do
        @types {:type, unquote(id), unquote(elements), unquote(type)}
      end
    end
    defp type({:::, _, [{id, _, nil}, spec]}, _acc, caller) do
      [type] = type(spec, [], caller)
      quote do
        @types {:type, unquote(id), nil, unquote(type)}
      end
    end
    defp type({:|, _, [{:=, _, [{id, _, nil}, first]}, right]}, acc, caller) do
      [right] = type(right, [], caller)
      acc = Enum.reverse [right|acc]
      {id, [first|acc]}
    end
    defp type({:|, _, [left, right]}, acc, caller) do
      [right] = type(right, [], caller)
      type(left, [right|acc], caller)
    end
    defp type({id, _, nil}, acc, _caller) do
      [id|acc]
    end
    defp type(left, acc, _caller) do
      [left|acc]
    end

    defmacro mapping(name, values) do
      to_value = lc {name, value} inlist values do
                   quote do: def to_value(unquote(name)), do: unquote(value)
                 end
      to_name = lc {name, value} inlist values do
                   quote do: def to_name(unquote(value)), do: unquote(name)
                 end
      quote do
        @mappings unquote(name)
        defmodule unquote(name) do
          unquote(to_value)
          unquote(to_name)
        end
      end
    end

    defmacro record(name, spec) do
      record(name, spec, __CALLER__)
    end

    defp record(name, spec, _caller) do
      {defaults, types} = split_spec(spec)
      types = lc {id, type} inlist types do
                quote do: def __type__(unquote(id)), do: unquote(Macro.escape(type))
              end
      quote do
        @records unquote(name)
        defrecord unquote(name), unquote(defaults) do
          unquote(types)
        end
      end
    end

    @private
    def split_spec(spec) do
      {defaults, types} = reduce spec, {[], []},
         (function do
           {id, nil, nil}, {defaults, types} ->
              {[{id, nil}|defaults], types}
           {id, default, nil}, {defaults, types} ->
              {[{id, default}|defaults], types}
           {id, default, type}, {defaults, types} ->
              {[{id, default}|defaults], [{id, type}|types]}
          end)
      {Keyword.from_enum(defaults), Keyword.from_enum(types)}
    end

    defp reduce([], acc, _fun), do: acc
    defp reduce([spec|rest], acc, fun) do
      reduce(rest, reduce(spec, acc, fun), fun)
    end
    defp reduce({id, {:::, _, [default, type]}}, acc, fun) do
      fun.({id, default, type}, acc)
    end
    defp reduce({:::, _, [id, type]}, acc, fun) do
      fun.({id, nil, type}, acc)
    end
    defp reduce({id, default}, acc, fun) do
      fun.({id, default, nil}, acc)
    end
    defp reduce(id, acc, fun) when is_atom(id) or is_binary(id) do
      fun.({id, nil, nil}, acc)
    end

  end

  def test do
    WDeX.WebDriver.Spec.start
    base = "http://127.0.0.1:7055/hub"
    WDeX.WebDriver.Spec.status base
    parts = redirect(WDeX.WebDriver.Spec.session base, [{"desiredCapabilities", []}])
    {_, [sessionId]} = Enum.split parts, -1
    WDeX.WebDriver.Spec.session_url "http://127.0.0.1:7055/hub", sessionId,
                                    url: "www.google.com"
  end
  defp redirect({:ok, 303, headers, _, _}) do
    IO.puts "headers: #{inspect headers}"
    location = Keyword.get(headers, "location", "")
    IO.puts "location: #{inspect location}"
    :binary.split(location, "/", [:global])
  end
end

"""
# not working
WDeX.WebDriver.Spec.sessions "http://127.0.0.1:7055/hub"
"""
