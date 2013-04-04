require 'lib/repo'

class Github < Repo
  attr_reader :open_issues

  def initialize(config)
    @username = config["username"]
    @api_token = config["api_token"]
    @repository = config["repository"]

    # http://developer.github.com/v3/issues/#list-issues-for-a-repository
    github = open("https://api.github.com/repos/#{@repository}/issues",
      :http_basic_authentication=>["#{@username}"]) do |f|
      JSON.parse(f.read)
    end

    @open_issues = github["issues"].map do |issue|
      Issue.new(issue["title"], issue["number"])
    end
    @issues_to_be_synched = @open_issues
  end
  
  # Returns number of new issue
  # http://developer.github.com/v3/issues/#create-an-issue
  def new_issue(title)
    result = YAML.load(RestClient.post("https://github.com/api/v2/yaml/issues/open/#{@repository}", :login => @username,
      :token => @api_token, :title => title))
    result["issue"]["number"]
  end
  
  # issues/edit/:user/:repo/:number
  # http://developer.github.com/v3/issues/#edit-an-issue
  def edit_issue(id, title)
    RestClient.post("https://github.com/api/v2/yaml/issues/edit/#{@repository}/#{id}", :login => @username,
      :token => @api_token, :title => title)
  end
  
  def system_name
    "GitHub"
  end
  
  def issues_name
    "GitHub issues"
  end
  
  def tag
    :github
  end
end
