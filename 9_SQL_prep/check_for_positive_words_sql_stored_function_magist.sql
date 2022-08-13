CREATE FUNCTION `check_for_positive_words` (
	review_comment_message TEXT
)
RETURNS BOOL
DETERMINISTIC
BEGIN
	DECLARE contains_positive_word BOOL;
    
    IF review_comment_message REGEXP 'bom|otimo|gostei|recomendo|excelente' THEN
		SET contains_positive_word = 'TRUE';
	ELSEIF NOT review_comment_message REGEXP 'bom|otimo|gostei|recomendo|excelente' THEN
		SET contains_positive_word = 'FALSE';
    END IF;
		RETURN contains_positive_word;
END