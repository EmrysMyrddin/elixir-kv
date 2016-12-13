defmodule KV.Bucket do
	@doc """
	Stqrts a new bucket
	"""
	def start_link do
		Agent.start_link fn -> %{}  end
	end

	@doc """
	Gets a value form the `bucket` by `key`
	"""
	def get(bucket, key) do
		Agent.get bucket, &Map.get(&1, key)
	end

	@doc """
	Puts the value `value` for the given `key` in the `bucket`
	"""
	def put(bucket, key, value) do
		Agent.update bucket, &Map.put(&1, key, value)
	end

	@doc """
	Deletes `key`form `bucket`.

	Returns the current value of `key`, if `key` exists.
	"""
	def delete(bucket, key) do
		Agent.get_and_update bucket, &Map.pop(&1, key)
	end
end