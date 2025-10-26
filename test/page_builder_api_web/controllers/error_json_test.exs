defmodule PageBuilderApiWeb.ErrorJSONTest do
  use PageBuilderApiWeb.ConnCase, async: true

  describe "render/2" do
    test "renders 404" do
      assert PageBuilderApiWeb.ErrorJSON.render("404.json", %{}) == %{
               errors: %{detail: "Not Found"}
             }
    end

    test "renders 500" do
      assert PageBuilderApiWeb.ErrorJSON.render("500.json", %{}) ==
               %{errors: %{detail: "Internal Server Error"}}
    end
  end
end
