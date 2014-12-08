require 'webrick'

class PackagecloudServer < WEBrick::HTTPServlet::AbstractServlet
  DISTRIBUTIONS = "{\"deb\":[{\"display_name\":\"Ubuntu\",\"index_name\":\"ubuntu\",\"versions\":[{\"id\":3,\"display_name\":\"5.10 Breezy Badger\",\"index_name\":\"breezy\",\"version_number\":\"5.10\"},{\"id\":4,\"display_name\":\"6.06 LTS Dapper Drake\",\"index_name\":\"dapper\",\"version_number\":\"6.06\"},{\"id\":5,\"display_name\":\"6.10 Edgy Eft\",\"index_name\":\"edgy\",\"version_number\":\"6.10\"},{\"id\":6,\"display_name\":\"7.04 Feisty Fawn\",\"index_name\":\"feisty\",\"version_number\":\"7.04\"},{\"id\":7,\"display_name\":\"7.10 Gutsy Gibbon\",\"index_name\":\"gutsy\",\"version_number\":\"7.10\"},{\"id\":8,\"display_name\":\"8.04 LTS Hardy Heron\",\"index_name\":\"hardy\",\"version_number\":\"8.04\"},{\"id\":2,\"display_name\":\"5.04 Hoary Hedgehog\",\"index_name\":\"hoary\",\"version_number\":\"5.04\"},{\"id\":9,\"display_name\":\"8.10 Intrepid Ibex\",\"index_name\":\"intrepid\",\"version_number\":\"8.10\"},{\"id\":10,\"display_name\":\"9.04 Jaunty Jackalope\",\"index_name\":\"jaunty\",\"version_number\":\"9.04\"},{\"id\":11,\"display_name\":\"9.10 Karmic Koala\",\"index_name\":\"karmic\",\"version_number\":\"9.10\"},{\"id\":12,\"display_name\":\"10.04 LTS Lucid Lynx\",\"index_name\":\"lucid\",\"version_number\":\"10.04\"},{\"id\":13,\"display_name\":\"10.10 Maverick Meerkat\",\"index_name\":\"maverick\",\"version_number\":\"10.10\"},{\"id\":14,\"display_name\":\"11.04 Natty Narwhal\",\"index_name\":\"natty\",\"version_number\":\"11.04\"},{\"id\":15,\"display_name\":\"11.10 Oneiric Ocelot\",\"index_name\":\"oneiric\",\"version_number\":\"11.10\"},{\"id\":16,\"display_name\":\"12.04 LTS Precise Pangolin\",\"index_name\":\"precise\",\"version_number\":\"12.04\"},{\"id\":17,\"display_name\":\"12.10 Quantal Quetzal\",\"index_name\":\"quantal\",\"version_number\":\"12.10\"},{\"id\":18,\"display_name\":\"13.04 Raring Ringtail\",\"index_name\":\"raring\",\"version_number\":\"13.04\"},{\"id\":19,\"display_name\":\"13.10 Saucy Salamander\",\"index_name\":\"saucy\",\"version_number\":\"13.10\"},{\"id\":20,\"display_name\":\"14.04 LTS[66] Trusty Tahr\",\"index_name\":\"trusty\",\"version_number\":\"14.04\"},{\"id\":1,\"display_name\":\"4.10 Warty Warthog\",\"index_name\":\"warty\",\"version_number\":\"4.10\"}]},{\"display_name\":\"Debian\",\"index_name\":\"debian\",\"versions\":[{\"id\":21,\"display_name\":\"4.0 etch\",\"index_name\":\"etch\",\"version_number\":\"4.0\"},{\"id\":25,\"display_name\":\"8 jessie\",\"index_name\":\"jessie\",\"version_number\":\"8.0\"},{\"id\":22,\"display_name\":\"5.0 lenny\",\"index_name\":\"lenny\",\"version_number\":\"5.0\"},{\"id\":23,\"display_name\":\"6.0 squeeze\",\"index_name\":\"squeeze\",\"version_number\":\"6.0\"},{\"id\":24,\"display_name\":\"7 wheezy\",\"index_name\":\"wheezy\",\"version_number\":\"7.0\"}]},{\"display_name\":\"Any deb-based distribution.\",\"index_name\":\"any\",\"versions\":[{\"id\":35,\"display_name\":\"Any version.\",\"index_name\":\"any\",\"version_number\":null}]}],\"rpm\":[{\"display_name\":\"Enterprise Linux\",\"index_name\":\"el\",\"versions\":[{\"id\":26,\"display_name\":\"Enterprise Linux 5.0\",\"index_name\":\"5\",\"version_number\":\"5.0\"},{\"id\":27,\"display_name\":\"Enterprise Linux 6.0\",\"index_name\":\"6\",\"version_number\":\"6.0\"},{\"id\":140,\"display_name\":\"Enterprise Linux 7.0\",\"index_name\":\"7\",\"version_number\":\"7.0\"}]},{\"display_name\":\"Fedora\",\"index_name\":\"fedora\",\"versions\":[{\"id\":28,\"display_name\":\"14 Laughlin\",\"index_name\":\"14\",\"version_number\":\"14.0\"},{\"id\":29,\"display_name\":\"15 Lovelock\",\"index_name\":\"15\",\"version_number\":\"15.0\"},{\"id\":30,\"display_name\":\"16 Verne\",\"index_name\":\"16\",\"version_number\":\"16.0\"},{\"id\":31,\"display_name\":\"17 Beefy Miracle\",\"index_name\":\"17\",\"version_number\":\"17.0\"},{\"id\":32,\"display_name\":\"18 Spherical Cow\",\"index_name\":\"18\",\"version_number\":\"18.0\"},{\"id\":33,\"display_name\":\"19 Schrödinger's Cat\",\"index_name\":\"19\",\"version_number\":\"19.0\"},{\"id\":34,\"display_name\":\"20 Heisenbug\",\"index_name\":\"20\",\"version_number\":\"20.0\"}]},{\"display_name\":\"Scientific Linux\",\"index_name\":\"scientific\",\"versions\":[{\"id\":138,\"display_name\":\"Scientific Linux 5.0\",\"index_name\":\"5\",\"version_number\":\"5.0\"},{\"id\":139,\"display_name\":\"Scientific Linux 6.0\",\"index_name\":\"6\",\"version_number\":\"6.0\"}]}],\"dsc\":[{\"display_name\":\"Ubuntu\",\"index_name\":\"ubuntu\",\"versions\":[{\"id\":3,\"display_name\":\"5.10 Breezy Badger\",\"index_name\":\"breezy\",\"version_number\":\"5.10\"},{\"id\":4,\"display_name\":\"6.06 LTS Dapper Drake\",\"index_name\":\"dapper\",\"version_number\":\"6.06\"},{\"id\":5,\"display_name\":\"6.10 Edgy Eft\",\"index_name\":\"edgy\",\"version_number\":\"6.10\"},{\"id\":6,\"display_name\":\"7.04 Feisty Fawn\",\"index_name\":\"feisty\",\"version_number\":\"7.04\"},{\"id\":7,\"display_name\":\"7.10 Gutsy Gibbon\",\"index_name\":\"gutsy\",\"version_number\":\"7.10\"},{\"id\":8,\"display_name\":\"8.04 LTS Hardy Heron\",\"index_name\":\"hardy\",\"version_number\":\"8.04\"},{\"id\":2,\"display_name\":\"5.04 Hoary Hedgehog\",\"index_name\":\"hoary\",\"version_number\":\"5.04\"},{\"id\":9,\"display_name\":\"8.10 Intrepid Ibex\",\"index_name\":\"intrepid\",\"version_number\":\"8.10\"},{\"id\":10,\"display_name\":\"9.04 Jaunty Jackalope\",\"index_name\":\"jaunty\",\"version_number\":\"9.04\"},{\"id\":11,\"display_name\":\"9.10 Karmic Koala\",\"index_name\":\"karmic\",\"version_number\":\"9.10\"},{\"id\":12,\"display_name\":\"10.04 LTS Lucid Lynx\",\"index_name\":\"lucid\",\"version_number\":\"10.04\"},{\"id\":13,\"display_name\":\"10.10 Maverick Meerkat\",\"index_name\":\"maverick\",\"version_number\":\"10.10\"},{\"id\":14,\"display_name\":\"11.04 Natty Narwhal\",\"index_name\":\"natty\",\"version_number\":\"11.04\"},{\"id\":15,\"display_name\":\"11.10 Oneiric Ocelot\",\"index_name\":\"oneiric\",\"version_number\":\"11.10\"},{\"id\":16,\"display_name\":\"12.04 LTS Precise Pangolin\",\"index_name\":\"precise\",\"version_number\":\"12.04\"},{\"id\":17,\"display_name\":\"12.10 Quantal Quetzal\",\"index_name\":\"quantal\",\"version_number\":\"12.10\"},{\"id\":18,\"display_name\":\"13.04 Raring Ringtail\",\"index_name\":\"raring\",\"version_number\":\"13.04\"},{\"id\":19,\"display_name\":\"13.10 Saucy Salamander\",\"index_name\":\"saucy\",\"version_number\":\"13.10\"},{\"id\":20,\"display_name\":\"14.04 LTS[66] Trusty Tahr\",\"index_name\":\"trusty\",\"version_number\":\"14.04\"},{\"id\":1,\"display_name\":\"4.10 Warty Warthog\",\"index_name\":\"warty\",\"version_number\":\"4.10\"}]},{\"display_name\":\"Debian\",\"index_name\":\"debian\",\"versions\":[{\"id\":21,\"display_name\":\"4.0 etch\",\"index_name\":\"etch\",\"version_number\":\"4.0\"},{\"id\":25,\"display_name\":\"8 jessie\",\"index_name\":\"jessie\",\"version_number\":\"8.0\"},{\"id\":22,\"display_name\":\"5.0 lenny\",\"index_name\":\"lenny\",\"version_number\":\"5.0\"},{\"id\":23,\"display_name\":\"6.0 squeeze\",\"index_name\":\"squeeze\",\"version_number\":\"6.0\"},{\"id\":24,\"display_name\":\"7 wheezy\",\"index_name\":\"wheezy\",\"version_number\":\"7.0\"}]},{\"display_name\":\"Any deb-based distribution.\",\"index_name\":\"any\",\"versions\":[{\"id\":35,\"display_name\":\"Any version.\",\"index_name\":\"any\",\"version_number\":null}]}]}"
  PACKAGE_CONTENTS = "{\"files\":[{\"filename\":\"jake_1.0.orig.tar.bz2\",\"size\":1108,\"md5sum\":\"a7a309b55424198ee98abcb8092d7be0\"},{\"filename\":\"jake_1.0-7.debian.tar.gz\",\"size\":1571,\"md5sum\":\"0fa5395e95ddf846b419e96575ce8044\"}]}"
  GEM_VERSION = "{\"major\":\"0\",\"minor\":\"2\",\"patch\":\"1\"}"
  REPO = '{"name": "test_repo","created_at": "2014-08-30T03:51:37.000Z","url": "https://packagecloud.io/joedamato/test_repo","last_push_human": "about 2 months ago","package_count_human": "4 packages","private": true,"fqname": "joedamato/test_repo"}'
  REPOS = "[#{REPO}]"

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
  def route(request, response)
    if request["Authorization"] && request["Authorization"] != "Basic dGVzdF90b2tlbjo="
      return forbidden_response(request, response)
    end
    path = request.path
    case path
      when "/api/v1/distributions.json"
        json_response(request, response, DISTRIBUTIONS)
      when "/api/v1/repos.json"
        if request.request_method == "GET"
          json_response(request, response, REPOS)
        else
          created_response(request, response)
        end
      when "/api/v1/repos/joedamato/test_repo.json"
        json_response(request, response, REPO)
      when "/api/v1/repos/joedamato/test_repo/packages.json"
        created_response(request, response)
      when "/api/v1/repos/joedamato/test_repo/packages/contents.json"
        plain_response(request, response, PACKAGE_CONTENTS)
      when "/api/v1/gem_version.json"
        json_response(request, response, GEM_VERSION)
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

end