defmodule HoneyBee.BucketTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, bucket} = HoneyBee.Bucket.start_link
    {:ok, bucket: bucket}
  end

  test "stores values by key", %{bucket: bucket} do
    assert HoneyBee.Bucket.get(bucket, "milk") == nil

    HoneyBee.Bucket.set(bucket, "milk", 3)
    assert HoneyBee.Bucket.get(bucket, "milk") == 3

    HoneyBee.Bucket.delete(bucket, "milk")
    assert HoneyBee.Bucket.get(bucket, "milk") == nil
  end
end
