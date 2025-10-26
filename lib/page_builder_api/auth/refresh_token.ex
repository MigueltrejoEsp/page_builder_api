defmodule PageBuilderApi.Auth.RefreshToken do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "refresh_tokens" do
    field :token, :string
    field :expires_at, :utc_datetime
    field :revoked_at, :utc_datetime

    belongs_to :user, PageBuilderApi.Auth.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(refresh_token, attrs) do
    refresh_token
    |> cast(attrs, [:token, :user_id, :expires_at, :revoked_at])
    |> validate_required([:token, :user_id, :expires_at])
    |> unique_constraint(:token)
    |> foreign_key_constraint(:user_id)
  end

  @doc """
  Generates a secure random refresh token string.
  """
  def generate_token do
    :crypto.strong_rand_bytes(32) |> Base.url_encode64(padding: false)
  end

  @doc """
  Creates a changeset for a new refresh token with a 30-day expiration.
  """
  def create_changeset(user_id) do
    %__MODULE__{}
    |> changeset(%{
      token: generate_token(),
      user_id: user_id,
      expires_at: DateTime.utc_now() |> DateTime.add(30, :day) |> DateTime.truncate(:second)
    })
  end
end
