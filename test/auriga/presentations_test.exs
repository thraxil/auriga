defmodule Auriga.PresentationsTest do
  use Auriga.DataCase

  alias Auriga.Presentations

  describe "presentations" do
    alias Auriga.Presentations.Presentation

    @valid_attrs %{title: "some title"}
    @update_attrs %{title: "some updated title"}
    @invalid_attrs %{title: nil}

    def presentation_fixture(attrs \\ %{}) do
      {:ok, presentation} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Presentations.create_presentation()

      presentation
    end

    test "list_presentations/0 returns all presentations" do
      presentation = presentation_fixture()
      assert Presentations.list_presentations() == [presentation]
    end

    # test "get_presentation!/1 returns the presentation with given id" do
    #   presentation = presentation_fixture() 
    #   assert Presentations.get_presentation!(presentation.id) == presentation
    # end

    test "create_presentation/1 with valid data creates a presentation" do
      assert {:ok, %Presentation{} = presentation} = Presentations.create_presentation(@valid_attrs)
      assert presentation.title == "some title"
    end

    test "create_presentation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Presentations.create_presentation(@invalid_attrs)
    end

    # test "update_presentation/2 with valid data updates the presentation" do
    #   presentation = presentation_fixture()
    #   assert {:ok, %Presentation{} = presentation} = Presentations.update_presentation(presentation, @update_attrs)
    #   assert presentation.title == "some updated title"
    # end

    # test "update_presentation/2 with invalid data returns error changeset" do
    #   presentation = presentation_fixture()
    #   assert {:error, %Ecto.Changeset{}} = Presentations.update_presentation(presentation, @invalid_attrs)
    #   assert presentation == Presentations.get_presentation!(presentation.id)
    # end

    test "delete_presentation/1 deletes the presentation" do
      presentation = presentation_fixture()
      assert {:ok, %Presentation{}} = Presentations.delete_presentation(presentation)
      assert_raise Ecto.NoResultsError, fn -> Presentations.get_presentation!(presentation.id) end
    end

    test "change_presentation/1 returns a presentation changeset" do
      presentation = presentation_fixture()
      assert %Ecto.Changeset{} = Presentations.change_presentation(presentation)
    end
  end
end
