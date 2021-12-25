addi r3,r5,3
beqz r3, .jump
addi r2, r4, 2
.jump:
xor r1, r2, r3
