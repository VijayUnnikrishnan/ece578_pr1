function [i, BKP_CNT_A, BKP_CNT_C, coll_det, A_tran_suc, C_tran_suc] = calc_new_simtime_A_transmit(i, vcs_en, A_backedup, C_backedup, CW_A, CW_C , DataSlot, BKP_CNT_A, BKP_CNT_C)
%BKP_CNT_A = CW_A;
%BKP_CNT_C = CW_C;
coll_det  = 0;
A_tran_suc = 0;
C_tran_suc = 0;

CWMAX_C = 1024;
CWMAX_A = 1024;
CWMIN_C = 4;
CWMIN_A = 4;

if (A_backedup)
    BKP_CNT_A = BKP_CNT_A;  %Continue from previous value if A was backed up earlier
else
    BKP_CNT_A = (randi((CW_A), 1,1)) - 1;
end

fprintf("NoComp:A is successful in Transmission \n" );
%bkoff_diffAC = BKP_CNT_C - BKP_CNT_A;
CW_A = CWMIN_A;
if (vcs_en)
    i = i + BKP_CNT_A + 1 + 2 + 1 + 2 + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + RTS + SIFS + CTS + SIFS + Dataslot + SIFS + ACK
else
    i = i + BKP_CNT_A + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + Dataslot + SIFS + ACK
end
C_backedup = 0;
A_backedup = 0;
BKP_CNT_A = BKP_CNT_A ;
BKP_CNT_C = BKP_CNT_C ; % Redundant
A_tran_suc = 1;
end  %% End of function