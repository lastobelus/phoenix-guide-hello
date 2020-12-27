defmodule Hello.CMS.Page do
  use Ecto.Schema
  import Ecto.Changeset

  alias Hello.CMS.Author

  schema "pages" do
    field :body, :string
    field :title, :string
    field :views, :integer, default: 0
    belongs_to :author, Author

    timestamps()
  end

  @spec changeset(
          {map, map} | %{:__struct__ => atom | %{__changeset__: map}, optional(atom) => any},
          :invalid | %{optional(:__struct__) => none, optional(atom | binary) => any}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(page, attrs) do
    page
    |> cast(attrs, [:title, :body])
    |> validate_required([:title, :body])
  end
end
