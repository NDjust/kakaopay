library(tidyverse)
# rm(list = ls())

users <- read_csv('users.csv')
dutchpay_claim <- read_csv('dutchpay_claim.csv')
dutchpay_claim_detail <- read_csv('dutchpay_claim_detail.csv')
# a_payment_trx <- read_csv('a_payment_trx.csv')

glimpse(users)
glimpse(dutchpay_claim)
glimpse(dutchpay_claim_detail)
# glimpse(a_payment_trx)
# 1) '��ġ���� ��û�� ���� ������� �������� ��ġ���� ���񽺸� �� ���� ����Ѵ�'
# ��� ������ ��������� �����Ͻÿ�
# - �ش� ���� ���� ����� ������ ������ �Բ� ��ü ���� ������ ����Ͻÿ�

dutchpay_claim_total <- left_join(dutchpay_claim, dutchpay_claim_detail, 
                                  by = 'claim_id')
glimpse(dutchpay_claim_total)

users_dutchpay_claim_total <- left_join(dutchpay_claim_total, users,  
                                        by = c('claim_user_id' = 'user_id'))
glimpse(users_dutchpay_claim_total)


## ������� ���� :
# ��ġ���̴� �� ����� ����������� ��û�Ѵ�. 
# ��û���� ����� �� ����(�۱�SEND) �� ���ڰ� �������� ������� ���ٰ� �� �� �ִ�.

# ����� : claim_id�� status�� CLAIM ���� ��� SEND ���� ����


## claim_id�� status�� CLAIM ����
users_dutchpay_claim_total %>% 
    group_by(claim_id) %>%
    filter(status == 'CLAIM') %>% 
    summarise(claim_n = n()) -> users_dutchpay_claim_count
glimpse(users_dutchpay_claim_count)


## claim_id�� status�� SEND ����
users_dutchpay_claim_total %>% 
    group_by(claim_id) %>%
    filter(status == 'SEND') %>% 
    mutate(send_n = n()) -> users_dutchpay_send_count
glimpse(users_dutchpay_send_count)


users_dutchpay_claim_send <- left_join(users_dutchpay_claim_count, users_dutchpay_send_count)
glimpse(users_dutchpay_claim_send)


users_dutchpay_claim_send$send_n <- replace(users_dutchpay_claim_send$send_n, 
                                            is.na(users_dutchpay_claim_send$send_n),
                                            0)
users_dutchpay_claim_send %>% 
    select(claim_id, claim_n, send_n) %>%
    mutate(response = send_n / claim_n) -> users_dutchpay_response

glimpse(users_dutchpay_response)
hist(users_dutchpay_response$response)

## ��ġ���� ���� ��뷮�� ���� :
#  "��ġ���� ��û�� ���� ������� �������� ��ġ���� ���񽺸� '�� ���� ���'�Ѵ�."
# ���� ������ �ƶ��� �ľ��ϸ� '������ �������� ��û����� �� �� ���� �����Ѵ�'��� �ؼ��� �� �ִ�. 
# ���⼭�� '���'�� ��û(CLAIM)�� �ǹ��Ѵ�.

## ��뷮 : claim_id�� status�� CLAIM ����

length(users_dutchpay_claim_total$claim_id)
length(unique(users_dutchpay_claim_total$claim_id))

users_dutchpay_response %>% 
    group_by(claim_id) %>%
    summarize(claim_no = n()) -> users_dutchpay_usage

claim_response_usage <- left_join(users_dutchpay_usage, 
                                  users_dutchpay_response,
                                  by = 'claim_id')
glimpse(claim_response_usage)
summary(claim_response_usage)


## ����м�
hist(claim_response_usage$response)
hist(claim_response_usage$claim_no)
plot(claim_response_usage$response, claim_response_usage$claim_no)

# ������ �����̹Ƿ� �Ǿ �������� �����Ͽ� �� �������� ������ ������踦 �����Ѵ�.
cor.test(claim_response_usage$response, claim_response_usage$claim_no, 
         alternative=c('greater'), method = 'pearson')

cor(claim_response_usage$response, claim_response_usage$claim_no, method = 'pearson')
