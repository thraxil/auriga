defmodule Auriga.Presentations do
  @moduledoc """
  The Presentations context.
  """

  import Ecto.Query, warn: false
  alias Auriga.Repo

  alias Auriga.Presentations.Presentation

  @doc """
  Returns the list of presentations.

  ## Examples

      iex> list_presentations()
      [%Presentation{}, ...]

  """
  def list_presentations do
    Repo.all(Presentation)
  end

  @doc """
  Gets a single presentation.

  Raises `Ecto.NoResultsError` if the Presentation does not exist.

  ## Examples

      iex> get_presentation!(123)
      %Presentation{}

      iex> get_presentation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_presentation!(id), do: Repo.get!(Presentation, id)

  @doc """
  Creates a presentation.

  ## Examples

      iex> create_presentation(%{field: value})
      {:ok, %Presentation{}}

      iex> create_presentation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_presentation(attrs \\ %{}) do
    %Presentation{}
    |> Presentation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a presentation.

  ## Examples

      iex> update_presentation(presentation, %{field: new_value})
      {:ok, %Presentation{}}

      iex> update_presentation(presentation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_presentation(%Presentation{} = presentation, attrs) do
    presentation
    |> Presentation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a presentation.

  ## Examples

      iex> delete_presentation(presentation)
      {:ok, %Presentation{}}

      iex> delete_presentation(presentation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_presentation(%Presentation{} = presentation) do
    Repo.delete(presentation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking presentation changes.

  ## Examples

      iex> change_presentation(presentation)
      %Ecto.Changeset{data: %Presentation{}}

  """
  def change_presentation(%Presentation{} = presentation, attrs \\ %{}) do
    Presentation.changeset(presentation, attrs)
  end
end
