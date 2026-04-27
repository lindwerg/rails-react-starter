require "rails_helper"

RSpec.describe "Api::V1::Posts", type: :request do
  let(:author) { create(:user) }
  let(:other)  { create(:user) }

  describe "GET /api/v1/posts" do
    before do
      create(:post, author: author, title: "Public")
      create(:post, :draft, author: author, title: "Draft")
    end

    it "lists published posts to anon users" do
      get "/api/v1/posts"
      expect(response).to have_http_status(:ok)
      titles = json_body[:data].pluck(:title)
      expect(titles).to contain_exactly("Public")
    end

    it "lists author's drafts to that author" do
      get "/api/v1/posts", headers: auth_headers_for(author)
      titles = json_body[:data].pluck(:title)
      expect(titles).to contain_exactly("Public", "Draft")
    end

    it "returns pagination meta" do
      get "/api/v1/posts"
      expect(json_body[:meta]).to include(:page, :pages, :count)
    end
  end

  describe "GET /api/v1/posts/:id" do
    let(:post_record) { create(:post, author: author) }

    it "returns the post" do
      get "/api/v1/posts/#{post_record.id}"
      expect(response).to have_http_status(:ok)
      expect(json_body[:title]).to eq(post_record.title)
    end

    it "returns 403 on someone else's draft" do
      draft = create(:post, :draft, author: author)
      get "/api/v1/posts/#{draft.id}", headers: auth_headers_for(other)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "POST /api/v1/posts" do
    let(:params) { { post: { title: "New", body: "Content", publish: true } } }

    it "creates a post for the current user" do
      expect { post "/api/v1/posts", params: params, headers: auth_headers_for(author) }
        .to change(Post, :count).by(1)
      expect(response).to have_http_status(:created)
      expect(json_body[:title]).to eq("New")
    end

    it "rejects unauthenticated requests" do
      post "/api/v1/posts", params: params
      expect(response).to have_http_status(:unauthorized)
    end

    it "validates input" do
      post "/api/v1/posts",
        params: { post: { title: "", body: "x" } },
        headers: auth_headers_for(author)
      expect(response).to have_http_status(:unprocessable_entity)
    end
  end

  describe "PATCH /api/v1/posts/:id" do
    let!(:post_record) { create(:post, author: author, title: "Old") }

    it "updates own post" do
      patch "/api/v1/posts/#{post_record.id}",
        params: { post: { title: "New", body: post_record.body } },
        headers: auth_headers_for(author)
      expect(response).to have_http_status(:ok)
      expect(post_record.reload.title).to eq("New")
    end

    it "forbids editing other user's post" do
      patch "/api/v1/posts/#{post_record.id}",
        params: { post: { title: "Hacked", body: "..." } },
        headers: auth_headers_for(other)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe "DELETE /api/v1/posts/:id" do
    let!(:post_record) { create(:post, author: author) }

    it "deletes own post" do
      expect { delete "/api/v1/posts/#{post_record.id}", headers: auth_headers_for(author) }
        .to change(Post, :count).by(-1)
      expect(response).to have_http_status(:no_content)
    end

    it "forbids deleting other user's post" do
      delete "/api/v1/posts/#{post_record.id}", headers: auth_headers_for(other)
      expect(response).to have_http_status(:forbidden)
    end
  end
end
