defmodule Hello.CMS.Author do
  use Ecto.Schema
  import Ecto.Changeset

  schema "authors" do
    field :bio, :string
    field :genre, :string
    field :role, :string
    has_many :pages, Page

    # cross-context dependency, which will be constrained to database joins in non-public
    # functions.
    belongs_to :user, Hello.Accounts.User

    timestamps()
  end

  @doc false
  def changeset(author, attrs) do
    author
    |> cast(attrs, [:bio, :role, :genre])
    |> validate_required([:bio, :role, :genre])
    |> unique_constraint(:user_id)
  end
end
