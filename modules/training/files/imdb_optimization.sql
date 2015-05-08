# These are the indexes I created to optimize the top queries for the imdb database.

# Query 1 (6):
ALTER TABLE cast_info ADD KEY `bk_ci_m_r_no` (`movie_id`,`role_id`,`nr_order`),  ADD KEY `bk_ci_p_m` (`person_id`,`movie_id`) , ADD KEY `bk_ci_pr` (person_role_id);

# Query 2 (10):
ALTER TABLE movie_info ADD KEY `bk_mi_m` (`movie_id`);

# Query 4 (1):
ALTER TABLE person_info ADD KEY `bk_pi_p` (person_id);

# Query 5 (2): RAND title
ALTER TABLE title ADD KEY `bk_t_k_i` (kind_id, id);

# Query 8 (5):
ALTER TABLE name ADD KEY `bk_n_n` (name(15));

# Query 20: 
ALTER TABLE users ADD KEY `bk_u_l` (last_login_date);

# Query (14):
ALTER TABLE char_name ADD KEY `bk_cn_n` (name(15));

