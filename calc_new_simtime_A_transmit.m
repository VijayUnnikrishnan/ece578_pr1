function [i, BKP_CNT_A, BKP_CNT_C, coll_det, A_tran_suc, C_tran_suc, CW_A] = calc_new_simtime_A_transmit(i, sim_time, hidterminal,  FrameSlot,  X_C_pkt_arr_time, C_tidx, vcs_en, A_backedup, C_backedup, CW_A, CW_C , DataSlot, BKP_CNT_A, BKP_CNT_C, DATA_RATE,dat_rt, RUNTIME)
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

%fprintf("NoComp:A is successful in Transmission \n" );
%bkoff_diffAC = BKP_CNT_C - BKP_CNT_A;
%CW_A = CWMIN_A;
if (vcs_en)
    i = i + BKP_CNT_A + 1 + 2 + 1 + 2 + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + RTS + SIFS + CTS + SIFS + Dataslot + SIFS + ACK

else

    i = i + BKP_CNT_A + 1 + DataSlot + 1+ 2 ; %Proceed the time by BKP + Dataslot + SIFS + ACK
end

C_backedup = 0;
A_backedup = 0;
BKP_CNT_A = BKP_CNT_A ;
BKP_CNT_C = BKP_CNT_C ; % Redundant

if(hidterminal && (C_tidx < (DATA_RATE(dat_rt) * RUNTIME) ))
    if((sim_time + (i + BKP_CNT_A + 1 + 2 + 1 + 2 + 1 + DataSlot + 1+ 2) < X_C_pkt_arr_time(C_tidx + 1) ) && vcs_en)
        A_tran_suc = 1;
        CW_A = CWMIN_A;

    elseif ((sim_time + (i + BKP_CNT_A + 1 + 2 + 1 + 2 ) < X_C_pkt_arr_time(C_tidx + 1) ))
        A_tran_suc = 1;
        CW_A = CWMIN_A;
    else
        A_tran_suc = 0;
         if (CW_A < CWMAX_A) CW_A = 2*CW_A; end
        CW_A = 2*CW_A;
        coll_det  = 1;
       % fprintf("Mode3 : A in collision \n" );
    end
else
    A_tran_suc = 1;
    CW_A = CWMIN_A;
end
end  %% End of function