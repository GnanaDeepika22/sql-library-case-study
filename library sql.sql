create database libraries;

use libraries;

create table publisher (publisher_name varchar(255) primary key, 
						publisher_address varchar(255),
                        publisher_phone varchar(255));
			
create table borrower (card_no int primary key,
						borrower_name varchar(255),
                        borrower_address varchar(255),
                        borrower_phone varchar(255));

create table books (book_id int primary key,
					book_title varchar(255),
                    publisher_name varchar(255),
                    foreign key(publisher_name) references publisher(publisher_name) 
                    on delete cascade on update cascade);

create table authors (author_id int primary  key auto_increment,
                     book_id int,
					 author_name varchar(255),
                     foreign key(book_id) references books(book_id)
                     on delete cascade on update cascade);
                     
create table library_branch (branch_id int primary key auto_increment,
							 branch_name varchar(255),
                             branch_address varchar(255));
                             
create table book_copies (copies_id int primary key auto_increment,
						  book_id int,
                          branch_id int,
                          book_copies int,
                          foreign key(book_id) references books(book_id)
                          on delete cascade on update cascade,
			              foreign key(branch_id) references library_branch(branch_id)
                          on delete cascade on update cascade);
                          
create table book_loans (loan_id int primary key auto_increment,
						 book_id int,
                         branch_id int,
                         card_no int,
                         loan_date varchar(255),
                         due_date varchar(255),
                         foreign key(book_id) references books(book_id)
                         on delete cascade on update cascade,
                         foreign key(branch_id) references library_branch(branch_id)
                         on delete cascade on update cascade,
                         foreign key(card_no) references borrower(card_no)
                         on delete cascade on update cascade);
                         

select * from authors;
select * from book_copies;
select * from book_loans;
select * from books;
select * from borrower;
select * from library_branch;
select * from publisher;

set sql_safe_updates = 0;

update book_loans set loan_date = replace(loan_date,"/","-"),
				      due_date = replace(due_date,"/","-");

-- Modifying data types

alter table book_loans add column l_date date;
update book_loans set l_date = str_to_date(`loan_date`, '%Y-%m-%d');
alter table book_loans drop column loan_date;
alter table book_loans change l_date loan_date date;

alter table book_loans add column d_date date;
update book_loans set d_date = str_to_date(`due_date`, '%Y-%m-%d');
alter table book_loans drop column due_date;
alter table book_loans change d_date due_date date;


-- 1.How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"? 5

select book_copies
from books b
join book_copies c
on b.book_id = c.book_id
join library_branch l
on c.branch_id = l.branch_id
where book_title = "The Lost Tribe" and branch_name = "sharpstown";

-- 2.How many copies of the book titled "The Lost Tribe" are owned by each library branch?

select branch_name, book_title, book_copies as total_copies
from books b
join book_copies c
on b.book_id = c.book_id
join library_branch l
on c.branch_id = l.branch_id
where book_title = "The Lost Tribe"
group by branch_name;

-- 3.Retrieve the names of all borrowers who do not have any books checked out? Jane Smith

select borrower_name
from borrower 
where card_no not in (select card_no from book_loans);

-- 4.For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, retrieve the book title, 
-- the borrower's name, and the borrower's address?

select b.book_title, br.borrower_name, br.borrower_address
from book_loans bl
join books b
on b.book_id = bl.book_id
join borrower br
on bl.card_no = br.card_no
join library_branch lb
on bl.branch_id = lb.branch_id
where branch_name = "Sharpstown" and due_date = '2018-02-03';

-- 5. For each library branch, retrieve the branch name and the total number of books loaned out from that branch?

select branch_name, count(*) as total_copies
from book_loans bl
join library_branch lb
on bl.branch_id = lb.branch_id
group by branch_name;

-- 6. Retrieve the names, addresses, and number of books checked out for all borrowers who have more than five books checked out?

select borrower_name, borrower_address, count(loan_id)
from borrower b
join book_loans l
on b.card_no = l.card_no
group by borrower_name
having count(loan_id)> 5;

-- 7.For each book authored by "Stephen King", retrieve the title and the number of copies owned by the library branch whose name is "Central".

select book_title, book_copies as total_copies
from books b
join authors a
on b.book_id = a.book_id
join book_copies c
on c.book_id = b.book_id
join library_branch lb
on lb.branch_id = c.branch_id
where author_name = "Stephen King" and branch_name = "Central";
