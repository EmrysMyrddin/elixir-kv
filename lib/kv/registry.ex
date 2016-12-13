defmodule KV.Registry do
	use GenServer

	################
	## Client API ##
	################

	@doc """
	Sarts the registry
	"""

	def start_link do
		GenServer.start_link(__MODULE__, :ok, [])
	end

	@doc """
	Looks up the bucket pid for `name` stored in `server`.

	Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
	"""
	def lookup(server, name) do
		GenServer.call server, {:lookup, name}
	end

	@doc """
	Ensures there is a bucket assoiciated to the given `name` in `server`.
	"""
	def create(server, name) do
		GenServer.cast server, {:create, name}
	end

	@doc """
	Stops the registry
	"""
	def stop(server) do
		GenServer.stop(server)
	end

	################
	## Server API ##
	################

	def init(:ok) do
		names = %{}
		refs = %{}
		{:ok, {names, refs}}
	end

	def handle_call({:lookup, name}, _from, {names, _} = state) do
		{:reply, Map.fetch(names, name), state}
	end

	def handle_call(request, from, state), do: super(request, from, state)
	

	def handle_cast({:create, name}, {names, refs} = state) do
		if Map.has_key?(names, name) do
			{:noreply, state}
		else
			{:ok, bucket} = KV.Bucket.start_link
			ref = Process.monitor bucket
			refs = Map.put refs, ref, name
			names = Map.put names, name, bucket
			{:noreply, {names, refs}}
		end
	end

	def handle_cast(request, state), do: super(request, state)


	def handle_info({:DOWN, ref, :process, _pid, _reason}, {names, refs}) do
		{name, refs} = Map.pop(refs, ref)
		names = Map.delete(names, name)
		{:noreply, {names, refs}}
	end

	def handle_info(msg, state), do: super(msg, state)
end