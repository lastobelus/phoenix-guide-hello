defmodule MyTest do
  use ExUnit.Case

  ExUnit.Case.register_attribute(__MODULE__, :fixtures, accumulate: true)

  ExUnit.Case.register_describe_attribute(__MODULE__, :describe_fixtures, accumulate: true)

  ExUnit.Case.register_module_attribute(__MODULE__, :module_fixtures, accumulate: true)

  @module_fixtures :user
  @module_fixtures {:post, insert: false}

  test "using module attribute", context do
    assert context.registered.module_fixtures == [{:post, insert: false}, :user]
    assert context.registered.describe_fixtures == []
    assert context.registered.fixtures == []
  end

  describe "using custom attribute" do
    @describe_fixtures :user
    @describe_fixtures {:post, insert: false}

    test "has module and describe attribute", context do
      assert context.registered.module_fixtures == [{:post, insert: false}, :user]
      assert context.registered.describe_fixtures == [{:post, insert: false}, :user]
      assert context.registered.fixtures == []
    end

    @fixtures :user
    @fixtures {:post, insert: false}
    test "has module, describe and test attributes", context do
      assert context.registered.module_fixtures == [{:post, insert: false}, :user]
      assert context.registered.describe_fixtures == [{:post, insert: false}, :user]
      assert context.registered.fixtures == [{:post, insert: false}, :user]
    end

    test "test attributes are cleared", context do
      assert context.registered.module_fixtures == [{:post, insert: false}, :user]
      assert context.registered.describe_fixtures == [{:post, insert: false}, :user]
      assert context.registered.fixtures == []
    end
  end

  describe "describe attributes are cleared" do
    test "has only module attribute", context do
      assert context.registered.module_fixtures == [{:post, insert: false}, :user]
      assert context.registered.describe_fixtures == []
      assert context.registered.fixtures == []
    end
  end
end
