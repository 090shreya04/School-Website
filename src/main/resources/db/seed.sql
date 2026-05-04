-- Seed data for project1

-- Attendance
INSERT INTO attendance (student_id, teacher_id, class, date, status, marked_at) VALUES 
(3, 3, '10', CURDATE(), 'present', NOW()),
(4, 3, '9', CURDATE(), 'absent', NOW());

-- Fees (assuming March 2026 for now, or use current month)
INSERT INTO fees (student_id, amount, transaction_id, payment_date, status, month, year) VALUES
(3, 12000.00, 'TXN1001', CURDATE(), 'paid', 'March', 2026),
(4, 15000.00, 'TXN1002', CURDATE(), 'pending', 'March', 2026);

-- Notices
INSERT INTO notices (title, content, created_at, created_by, target_role) VALUES
('Holika Dahan Holiday', 'The school will remain closed tomorrow on account of Holika Dahan.', NOW(), 1, 'all');

-- Results (just for completeness)
INSERT INTO results (student_id, subject_id, marks_obtained, total_marks, grade, exam_type, exam_date) VALUES
(3, 1, 85, 100, 'A', 'Half Yearly', '2026-03-01');
