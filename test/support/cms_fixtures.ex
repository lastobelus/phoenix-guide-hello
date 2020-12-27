defmodule Support.CMS.Fixtures do
  @moduledoc false

  alias Hello.{Accounts, CMS}
  @valid_user_attrs %{name: "some name", username: "some username"}

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(@valid_user_attrs)
      |> Accounts.create_user()

    user
  end

  def user_author_fixture(user \\ nil, user_attrs \\ %{}) do
    user =
      case user do
        nil -> user_fixture(user_attrs)
        _ -> user
      end

    CMS.ensure_author_exists(user)
  end
end
