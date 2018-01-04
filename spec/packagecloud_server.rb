# encoding: utf-8
require 'webrick'

class PackagecloudServer < WEBrick::HTTPServlet::AbstractServlet
  DISTRIBUTIONS = File.read("spec/fixtures/distros.json")
  PACKAGE_CONTENTS = "{\"files\":[{\"filename\":\"jake_1.0.orig.tar.bz2\",\"size\":1108,\"md5sum\":\"a7a309b55424198ee98abcb8092d7be0\"},{\"filename\":\"jake_1.0-7.debian.tar.gz\",\"size\":1571,\"md5sum\":\"0fa5395e95ddf846b419e96575ce8044\"}]}"
  GEM_VERSION = "{\"major\":\"0\",\"minor\":\"2\",\"patch\":\"1\"}"
  REPO = '{"name": "test_repo","created_at": "2014-08-30T03:51:37.000Z","url": "https://packagecloud.io/joedamato/test_repo","last_push_human": "about 2 months ago","package_count_human": "4 packages","private": true,"fqname": "joedamato/test_repo"}'
  REPOS = "[#{REPO}]"
  READ_TOKENS = '{"read_tokens":[{"id":"1","name":"testread","value":"notreal"}]}'

  def json_response(request, response, body)
    response.status = 200
    response['Content-Type'] = "application/json"
    response.body = body
    $request, $response = request, response
  end

  def plain_response(request, response, body)
    response.status = 200
    response['Content-Type'] = "text/plain"
    response.body = body
    $request, $response = request, response
  end

  def created_response(request, response)
    response.status = 201
    response['Content-Type'] = "text/plain"
    response.body = "{}"
    ### Cheap hack to avoid parsing a multipart request here,
    ### instead we just check that the body isn't impossibly small
    if (request.body.size < 1000)
      raise "Request is too small! #{request.body.size}"
    end
    $request, $response = request, response
  end

  def default_response(request, response)
    response.status = 404
    response['Content-Type'] = "text/plain"
    response.body = "nope"
    $request, $response = request, response
  end

  def forbidden_response(request, response)
    response.status = 401
    response['Content-Type'] = "text/plain"
    response.body = "{ 'error': 'unauthenticated' }"

    $request, $response = request, response
  end

  def nocontent_response(request, response)
    response.status = 204
    response['Content-Type'] = 'text/plain'
    response.body = ''
    $request, $response = request, response
  end

  def can_acess?(request)
    request["Authorization"] == "Basic dGVzdF90b2tlbjo="
  end

  def route(request, response)
    return forbidden_response(request, response) unless can_acess?(request)

    path = request.path
    case path
      when "/api/v1/distributions.json"
        json_response(request, response, DISTRIBUTIONS)
      when "/api/v1/repos.json"
        if request.request_method == "GET"
          json_response(request, response, REPOS)
        else
          plain_response(request, response, "{}")
        end
      when "/api/v1/repos/joedamato/test_repo.json"
        json_response(request, response, REPO)
      when "/api/v1/repos/joedamato/test_repo/packages.json"
        created_response(request, response)
      when "/api/v1/repos/joedamato/test_repo/packages/contents.json"
        plain_response(request, response, PACKAGE_CONTENTS)
      when "/api/v1/gem_version.json"
        json_response(request, response, GEM_VERSION)
      when "/api/v1/repos/joedamato/test_repo/master_tokens/test_master_token/read_tokens.json"
        json_response(request, response, READ_TOKENS)
      else
        default_response(request, response)
        $request, $response = request, response
    end
  end

  def do_GET(request, response)
    route(request, response)
  end

  def do_POST(request, response)
    route(request, response)
  end

  def do_DELETE(request, response)
    return forbidden_response(request, response) unless can_acess?(request)

    path = request.path
    case path
      when "/api/v1/repos/joedamato/test_repo/master_tokens/test_master_token/read_tokens/1"
        nocontent_response(request, response)
      else
        default_response(request, response)
    end
  end
end
