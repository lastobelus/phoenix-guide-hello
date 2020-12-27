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

  def user_author_fixture(user_attrs \\ %{}) do
    user = user_fixture(user_attrs)
    CMS.ensure_author_exists(user)
  end
end
