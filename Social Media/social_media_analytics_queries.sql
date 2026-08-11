/*
 ============================================================
 Social Media Analytics SQL Project
 ============================================================
 Database dialect: MySQL 8+
 Purpose: Analyze user activity, engagement, hashtags,
          followers, posting patterns, and country-level trends.

 Expected tables:
 users, posts, comments, likes, followers,
 hashtags, post_hashtags

 Author: Mo. Fuzail Salmani
 ============================================================
*/

-- ============================================================
-- Q1. Top 10 Most Active Users
-- Measure activity using total posts + total comments.
-- ============================================================
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    COUNT(DISTINCT p.post_id) + COUNT(DISTINCT c.comment_id) AS total_activity
FROM users AS u
LEFT JOIN posts AS p
    ON u.user_id = p.user_id
LEFT JOIN comments AS c
    ON u.user_id = c.user_id
GROUP BY
    u.user_id,
    u.username
ORDER BY
    total_activity DESC
LIMIT 10;


-- ============================================================
-- Q2. Top 10 Most Liked Posts
-- Identify highly engaging posts and their creators.
-- ============================================================
SELECT
    p.post_id,
    p.content,
    u.username AS creator,
    COUNT(l.like_id) AS total_likes
FROM posts AS p
JOIN users AS u
    ON p.user_id = u.user_id
LEFT JOIN likes AS l
    ON p.post_id = l.post_id
GROUP BY
    p.post_id,
    p.content,
    u.username
ORDER BY
    total_likes DESC
LIMIT 10;


-- ============================================================
-- Q3. Top 5 Countries by Average Post Engagement
-- Engagement is measured as average likes per post.
-- ============================================================
SELECT
    country,
    ROUND(AVG(total_likes), 2) AS avg_likes_per_post
FROM (
    SELECT
        u.country,
        p.post_id,
        COUNT(l.like_id) AS total_likes
    FROM users AS u
    JOIN posts AS p
        ON u.user_id = p.user_id
    LEFT JOIN likes AS l
        ON p.post_id = l.post_id
    GROUP BY
        u.country,
        p.post_id
) AS post_engagement
GROUP BY
    country
ORDER BY
    avg_likes_per_post DESC
LIMIT 5;


-- ============================================================
-- Q4. Trending Hashtags
-- Find hashtags used in more than 20 posts.
-- ============================================================
SELECT
    h.hashtag_id,
    h.tag_name,
    COUNT(ph.post_id) AS total_posts
FROM hashtags AS h
JOIN post_hashtags AS ph
    ON h.hashtag_id = ph.hashtag_id
GROUP BY
    h.hashtag_id,
    h.tag_name
HAVING
    COUNT(ph.post_id) > 20
ORDER BY
    total_posts DESC;


-- Additional analysis: maximum number of posts associated
-- with any single hashtag.
SELECT
    MAX(post_count) AS max_posts_for_any_hashtag
FROM (
    SELECT
        hashtag_id,
        COUNT(post_id) AS post_count
    FROM post_hashtags
    GROUP BY
        hashtag_id
) AS hashtag_usage;


-- ============================================================
-- Q5. Top 5 Influencers
-- Rank users by number of followers.
-- ============================================================
SELECT
    u.user_id,
    u.username,
    COUNT(f.follower_user_id) AS total_followers
FROM followers AS f
JOIN users AS u
    ON f.user_id = u.user_id
GROUP BY
    u.user_id,
    u.username
ORDER BY
    total_followers DESC
LIMIT 5;


-- ============================================================
-- Q6. Users Who Follow Others but Never Like or Comment
-- Identify users who have following activity but no likes/comments.
-- ============================================================
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT f.user_id) AS following_count
FROM users AS u
JOIN followers AS f
    ON u.user_id = f.follower_user_id
WHERE NOT EXISTS (
    SELECT 1
    FROM likes AS l
    WHERE l.user_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1
    FROM comments AS c
    WHERE c.user_id = u.user_id
)
GROUP BY
    u.user_id,
    u.username
ORDER BY
    following_count DESC;


-- ============================================================
-- Q7. Hashtags with the Highest Engagement
-- Engagement = total likes + total comments across hashtag posts.
-- ============================================================
SELECT
    h.hashtag_id,
    h.tag_name,
    COUNT(DISTINCT l.like_id)
        + COUNT(DISTINCT c.comment_id) AS hashtag_engagement
FROM hashtags AS h
JOIN post_hashtags AS ph
    ON h.hashtag_id = ph.hashtag_id
JOIN posts AS p
    ON ph.post_id = p.post_id
LEFT JOIN likes AS l
    ON p.post_id = l.post_id
LEFT JOIN comments AS c
    ON p.post_id = c.post_id
GROUP BY
    h.hashtag_id,
    h.tag_name
ORDER BY
    hashtag_engagement DESC
LIMIT 1;


-- ============================================================
-- Q8. Busiest Posting Days and Hours
-- Find the day/hour combinations with the highest post activity.
-- ============================================================
SELECT
    DAYNAME(created_at) AS posting_day,
    HOUR(created_at) AS posting_hour,
    COUNT(*) AS total_posts
FROM posts
GROUP BY
    DAYNAME(created_at),
    HOUR(created_at)
ORDER BY
    total_posts DESC,
    posting_day,
    posting_hour;


-- ============================================================
-- Q9. Inactive Users
-- Users with no posts, likes, or comments.
-- ============================================================
SELECT
    u.user_id,
    u.username
FROM users AS u
WHERE NOT EXISTS (
    SELECT 1
    FROM posts AS p
    WHERE p.user_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1
    FROM likes AS l
    WHERE l.user_id = u.user_id
)
AND NOT EXISTS (
    SELECT 1
    FROM comments AS c
    WHERE c.user_id = u.user_id
);


-- ============================================================
-- Q10. Top 5 Countries by Number of Influencers
-- Count users who have at least one follower.
-- ============================================================
SELECT
    u.country,
    COUNT(DISTINCT f.user_id) AS total_influencers
FROM users AS u
JOIN followers AS f
    ON u.user_id = f.user_id
GROUP BY
    u.country
ORDER BY
    total_influencers DESC
LIMIT 5;


-- ============================================================
-- BONUS 1. User Engagement Rate
-- Formula: (likes + comments) / posts
-- ============================================================
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS total_posts,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    ROUND(
        (
            COUNT(DISTINCT l.like_id)
            + COUNT(DISTINCT c.comment_id)
        ) * 1.0
        / NULLIF(COUNT(DISTINCT p.post_id), 0),
        2
    ) AS engagement_rate
FROM users AS u
LEFT JOIN posts AS p
    ON u.user_id = p.user_id
LEFT JOIN likes AS l
    ON p.post_id = l.post_id
LEFT JOIN comments AS c
    ON p.post_id = c.post_id
GROUP BY
    u.user_id,
    u.username
ORDER BY
    engagement_rate DESC;


-- ============================================================
-- BONUS 2. Mutual Followers
-- Find users who follow each other.
-- ============================================================
SELECT
    u.user_id,
    u.username,
    COUNT(DISTINCT f1.follower_user_id) AS mutual_followers
FROM followers AS f1
JOIN followers AS f2
    ON f1.user_id = f2.follower_user_id
   AND f1.follower_user_id = f2.user_id
JOIN users AS u
    ON f1.user_id = u.user_id
GROUP BY
    u.user_id,
    u.username
ORDER BY
    mutual_followers DESC;


-- ============================================================
-- BONUS 3. Most Used Hashtags by Top 5 Influencers
-- ============================================================
SELECT
    u.user_id,
    u.username,
    h.hashtag_id,
    h.tag_name,
    COUNT(DISTINCT ph.post_id) AS hashtag_usage
FROM (
    SELECT
        f.user_id,
        COUNT(DISTINCT f.follower_user_id) AS total_followers
    FROM followers AS f
    GROUP BY
        f.user_id
    ORDER BY
        total_followers DESC
    LIMIT 5
) AS top_influencers
JOIN users AS u
    ON top_influencers.user_id = u.user_id
JOIN posts AS p
    ON u.user_id = p.user_id
JOIN post_hashtags AS ph
    ON p.post_id = ph.post_id
JOIN hashtags AS h
    ON ph.hashtag_id = h.hashtag_id
GROUP BY
    u.user_id,
    u.username,
    h.hashtag_id,
    h.tag_name
ORDER BY
    hashtag_usage DESC
LIMIT 5;


-- ============================================================
-- BONUS 4. Country-wise Engagement Leaderboard
-- Rank countries by total likes + comments.
-- ============================================================
SELECT
    u.country,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    COUNT(DISTINCT l.like_id)
        + COUNT(DISTINCT c.comment_id) AS total_engagement
FROM users AS u
JOIN posts AS p
    ON u.user_id = p.user_id
LEFT JOIN likes AS l
    ON p.post_id = l.post_id
LEFT JOIN comments AS c
    ON p.post_id = c.post_id
GROUP BY
    u.country
ORDER BY
    total_engagement DESC
LIMIT 10;
