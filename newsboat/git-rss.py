#! /usr/bin/env nix-shell
#! nix-shell -i python3 -p "python3.withPackages(ps: with ps; [GitPython])"

# Quick an ugly script to generate a rss feed from a git repo
import re
import sys
import email.utils
import xml.etree.ElementTree as ET
from git import Repo
from git import NoSuchPathError


def str_to_remote_name(string):
    # The format is not entirely clear, so let's just go with something simple.
    return re.sub(r'[^a-zA-Z0-9]', '-', string)

def get_updates(url, branch, web_url_template):
    name = str_to_remote_name(url)

    repo_path = "~/.cache/newsboat/git-tracker"
    try:
        repo = Repo(repo_path)
    except NoSuchPathError:
        repo = Repo.init(repo_path, mkdir=True)

    try:
        remote = repo.remote(name)
        assert list(remote.urls) == [url]
    except ValueError:
        remote = repo.create_remote(name, url)
        assert remote.exists()
    # Parallelism
    # https://github.com/gitpython-developers/GitPython/issues/584#issuecomment-282474005
    remote.fetch()

    history = repo.iter_commits(remote.refs[branch])

    for commit in history:
        yield generate_rss_item(
            title=commit.summary,
            content="\n".join(commit.message.splitlines()[2:]),
            link=web_url_template.format(commit.hexsha),
            author=commit.author,
            date=email.utils.format_datetime(commit.committed_datetime),
        )


def generate_rss_item(title, content, link, author, date):
    item = ET.Element("item")
    ET.SubElement(item, "title").text = title
    ET.SubElement(item, "description").text = content
    ET.SubElement(item, "link").text = link
    ET.SubElement(item, "author").text = author
    ET.SubElement(item, "guid").text = link
    ET.SubElement(item, "pubDate").text = date
    return item


def format_rss(posts):
    rss_root = ET.Element("rss", {"version": "2.0"})
    channel = ET.SubElement(rss_root, "channel")
    description = ET.SubElement(channel, "description", text="Channel desccription") # TODO data
    link = ET.SubElement(channel, "link", text="something")
    title = ET.SubElement(channel, "title", text="Some patreon feed")
    for post in posts:
        channel.append(post)
    return rss_root


def _main():
    url = sys.argv[1]
    branch = sys.argv[2] if len(sys.argv) > 2 else "master"
    web_url_template = sys.argv[3] if len(sys.argv) > 3 else url + "/{}"
    posts = get_updates(url, branch, web_url_template)
    xml = format_rss(posts)
    print(ET.tostring(xml, encoding="unicode", short_empty_elements=False))


if __name__ == "__main__":
    _main()
