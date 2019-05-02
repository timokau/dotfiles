#!/usr/bin/env python3

# quick an ugly script to generate a rss fead from a patreon creator (public posts only, no login mechanism)
import urllib.request
import json
import html
import sys

def fetch_posts(creator_id):
    # API url sniffed from visiting patreon.com/bcachefs/posts in a web brwoser and cut to relevant fields
    url = 'https://www.patreon.com/api/stream?include=poll.choices,poll.current_user_responses.user,poll.current_user_responses.choice,poll.current_user_responses.poll&fields[post]=comment_count,content,like_count,published_at,post_type,thumbnail_url,title,url&page[cursor]=null&filter[is_by_creator]=true&filter[is_following]=false&sort=-published_at&filter[creator_id]={}&filter[contains_exclusive_posts]=true&json-api-use-default-includes=false&json-api-version=1.0'.format(creator_id)
    with urllib.request.urlopen(url) as response:
        response = json.loads(response.read())
        return response

def post_to_rss(title, content, link, author, id, date):
    rss_item_template = """<item>
      <title>{title}</title>
      <description>{content}</description>
      <link>{link}</link>
      <author>{author}</author>
      <guid>{link}</guid>
      <pubDate>{date}</pubDate>
    </item>"""
    return rss_item_template.format(
        title = title,
        content = content,
        link = link,
        author = author,
        # id = id,
        id = link, # for some reason id is expected to be a permalink
        date = date,
    )

def format_rss(posts):
    feed_template = """<?xml version="1.0" encoding="utf-8"? standalone="yes" ?>
<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
    <description>Channel description</description>
    <link>https://www.patreon.com</link>
    <title>Some pateron feed</title>
    {items}
    </channel>
</rss>"""
    posts_str = '\n'.join(posts)
    return feed_template.format(items = posts_str)

def json_to_rss(json):
    rss_posts = []
    for post in json['data']:
        rss_posts += [
            post_to_rss(
                html.escape(post['attributes']['title']),
                html.escape(post['attributes']['content']),
                post['attributes']['url'],
                "creator@patreon.com (Pateron Creator)",
                post['id'],
                post['attributes']['published_at'],
            )
        ]
    return format_rss(rss_posts)

def patreon_to_rss(creator_id):
    return json_to_rss(fetch_posts(creator_id))

creator_id = sys.argv[1]
print(patreon_to_rss(creator_id))
