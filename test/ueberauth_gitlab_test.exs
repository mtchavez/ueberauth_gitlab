defmodule UeberauthGitlabTest do
  use ExUnit.Case, async: false
  use Plug.Test

  import Plug.Conn

  doctest UeberauthGitlab

  def set_options(routes, conn, opt) do
    case Enum.find_index(routes, &(elem(&1, 0) == {conn.request_path, conn.method})) do
      nil ->
        routes

      idx ->
        update_in(routes, [Access.at(idx), Access.elem(1), Access.elem(2)], &%{&1 | options: opt})
    end
  end

  test "handle_request!" do
    conn =
      conn(:get, "/auth/gitlab", %{
        client_id: "12345",
        client_secret: "98765",
        redirect_uri: "http://localhost:4000/auth/gitlab/callback"
      })

    routes =
      Ueberauth.init()
      |> set_options(conn, default_scope: "read_user")

    resp = Ueberauth.call(conn, routes)

    assert resp.status == 302
    assert [location] = get_resp_header(resp, "location")

    redirect_uri = URI.parse(location)
    assert redirect_uri.host == "gitlab.com"
    assert redirect_uri.path == "/oauth/authorize"

    assert %{
             "client_id" => "test_client_id",
             "redirect_uri" => "http://www.example.com/auth/gitlab/callback",
             "response_type" => "code",
             "scope" => "read_user"
           } = Plug.Conn.Query.decode(redirect_uri.query)
  end

  describe "handle_callback!" do
    test "with no code" do
      conn = %Plug.Conn{}
      result = Ueberauth.Strategy.Gitlab.handle_callback!(conn)
      failure = result.assigns.ueberauth_failure
      assert length(failure.errors) == 1
      [no_code_error] = failure.errors

      assert no_code_error.message_key == "missing_code"
      assert no_code_error.message == "No code received"
    end
  end

  describe "handle_cleanup!" do
    test "clears gitlab_user from conn" do
      conn =
        %Plug.Conn{}
        |> Plug.Conn.put_private(:gitlab_user, %{username: "mtchavez"})
        |> Plug.Conn.put_private(:gitlab_token, "test-token")

      result = Ueberauth.Strategy.Gitlab.handle_cleanup!(conn)
      assert result.private.gitlab_user == nil
      assert result.private.gitlab_token == nil
    end
  end

  describe "uid" do
    test "uid_field not found" do
      conn =
        %Plug.Conn{}
        |> Plug.Conn.put_private(:gitlab_user, %{uid: "not-found-uid"})

      assert Ueberauth.Strategy.Gitlab.uid(conn) == nil
    end

    test "uid_field returned" do
      uid = "abcd1234abcd1234"

      conn =
        %Plug.Conn{}
        |> Plug.Conn.put_private(:gitlab_user, %{"id" => uid})

      assert Ueberauth.Strategy.Gitlab.uid(conn) == uid
    end
  end

  describe "credentials" do
    test "are returned" do
      conn =
        %Plug.Conn{}
        |> Plug.Conn.put_private(:gitlab_token, %{
          access_token: "access-token",
          refresh_token: "refresh-token",
          expires: false,
          expires_at: Time.utc_now(),
          token_type: "access_code",
          other_params: %{}
        })

      creds = Ueberauth.Strategy.Gitlab.credentials(conn)
      assert creds.token == "access-token"
      assert creds.refresh_token == "refresh-token"
      assert creds.expires == true
      assert creds.scopes == [""]
    end
  end

  describe "info" do
    test "is returned" do
      conn =
        %Plug.Conn{}
        |> Plug.Conn.put_private(:gitlab_user, %{
          "name" => "mtchavez",
          "username" => "mtchavez",
          "email" => "m@t.chavez",
          "location" => "",
          "avatar_url" => "http://the.image.url",
          "web_url" => "https://gitlab.com/mtchavez",
          "website_url" => ""
        })

      info = Ueberauth.Strategy.Gitlab.info(conn)
      assert info.name == "mtchavez"
      assert info.nickname == "mtchavez"
      assert info.email == "m@t.chavez"
      assert info.location == ""
      assert info.image == "http://the.image.url"
      assert info.urls.web_url == "https://gitlab.com/mtchavez"
      assert info.urls.website_url == ""
    end
  end
end
