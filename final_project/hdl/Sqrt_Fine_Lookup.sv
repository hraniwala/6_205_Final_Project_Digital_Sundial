module Sqrt_Fine_Lookup(
    input wire [31:0] sqrt_input,
    output logic [11:0] sqrt_output);

    always_comb begin
        if ((sqrt_input > 31'd25) && (sqrt_input <= 31'd100)) begin
                sqrt_output = 11'd5;
        end else if ((sqrt_input > 31'd100) && (sqrt_input <= 31'd225)) begin
                sqrt_output = 11'd10;
        end else if ((sqrt_input > 31'd225) && (sqrt_input <= 31'd400)) begin
                sqrt_output = 11'd15;
        end else if ((sqrt_input > 31'd400) && (sqrt_input <= 31'd625)) begin
                sqrt_output = 11'd20;
        end else if ((sqrt_input > 31'd625) && (sqrt_input <= 31'd900)) begin
                sqrt_output = 11'd25;
        end else if ((sqrt_input > 31'd900) && (sqrt_input <= 31'd1225)) begin
                sqrt_output = 11'd30;
        end else if ((sqrt_input > 31'd1225) && (sqrt_input <= 31'd1600)) begin
                sqrt_output = 11'd35;
        end else if ((sqrt_input > 31'd1600) && (sqrt_input <= 31'd2025)) begin
                sqrt_output = 11'd40;
        end else if ((sqrt_input > 31'd2025) && (sqrt_input <= 31'd2500)) begin
                sqrt_output = 11'd45;
        end else if ((sqrt_input > 31'd2500) && (sqrt_input <= 31'd3025)) begin
                sqrt_output = 11'd50;
        end else if ((sqrt_input > 31'd3025) && (sqrt_input <= 31'd3600)) begin
                sqrt_output = 11'd55;
        end else if ((sqrt_input > 31'd3600) && (sqrt_input <= 31'd4225)) begin
                sqrt_output = 11'd60;
        end else if ((sqrt_input > 31'd4225) && (sqrt_input <= 31'd4900)) begin
                sqrt_output = 11'd65;
        end else if ((sqrt_input > 31'd4900) && (sqrt_input <= 31'd5625)) begin
                sqrt_output = 11'd70;
        end else if ((sqrt_input > 31'd5625) && (sqrt_input <= 31'd6400)) begin
                sqrt_output = 11'd75;
        end else if ((sqrt_input > 31'd6400) && (sqrt_input <= 31'd7225)) begin
                sqrt_output = 11'd80;
        end else if ((sqrt_input > 31'd7225) && (sqrt_input <= 31'd8100)) begin
                sqrt_output = 11'd85;
        end else if ((sqrt_input > 31'd8100) && (sqrt_input <= 31'd9025)) begin
                sqrt_output = 11'd90;
        end else if ((sqrt_input > 31'd9025) && (sqrt_input <= 31'd10000)) begin
                sqrt_output = 11'd95;
        end else if ((sqrt_input > 31'd10000) && (sqrt_input <= 31'd11025)) begin
                sqrt_output = 11'd100;
        end else if ((sqrt_input > 31'd11025) && (sqrt_input <= 31'd12100)) begin
                sqrt_output = 11'd105;
        end else if ((sqrt_input > 31'd12100) && (sqrt_input <= 31'd13225)) begin
                sqrt_output = 11'd110;
        end else if ((sqrt_input > 31'd13225) && (sqrt_input <= 31'd14400)) begin
                sqrt_output = 11'd115;
        end else if ((sqrt_input > 31'd14400) && (sqrt_input <= 31'd15625)) begin
                sqrt_output = 11'd120;
        end else if ((sqrt_input > 31'd15625) && (sqrt_input <= 31'd16900)) begin
                sqrt_output = 11'd125;
        end else if ((sqrt_input > 31'd16900) && (sqrt_input <= 31'd18225)) begin
                sqrt_output = 11'd130;
        end else if ((sqrt_input > 31'd18225) && (sqrt_input <= 31'd19600)) begin
                sqrt_output = 11'd135;
        end else if ((sqrt_input > 31'd19600) && (sqrt_input <= 31'd21025)) begin
                sqrt_output = 11'd140;
        end else if ((sqrt_input > 31'd21025) && (sqrt_input <= 31'd22500)) begin
                sqrt_output = 11'd145;
        end else if ((sqrt_input > 31'd22500) && (sqrt_input <= 31'd24025)) begin
                sqrt_output = 11'd150;
        end else if ((sqrt_input > 31'd24025) && (sqrt_input <= 31'd25600)) begin
                sqrt_output = 11'd155;
        end else if ((sqrt_input > 31'd25600) && (sqrt_input <= 31'd27225)) begin
                sqrt_output = 11'd160;
        end else if ((sqrt_input > 31'd27225) && (sqrt_input <= 31'd28900)) begin
                sqrt_output = 11'd165;
        end else if ((sqrt_input > 31'd28900) && (sqrt_input <= 31'd30625)) begin
                sqrt_output = 11'd170;
        end else if ((sqrt_input > 31'd30625) && (sqrt_input <= 31'd32400)) begin
                sqrt_output = 11'd175;
        end else if ((sqrt_input > 31'd32400) && (sqrt_input <= 31'd34225)) begin
                sqrt_output = 11'd180;
        end else if ((sqrt_input > 31'd34225) && (sqrt_input <= 31'd36100)) begin
                sqrt_output = 11'd185;
        end else if ((sqrt_input > 31'd36100) && (sqrt_input <= 31'd38025)) begin
                sqrt_output = 11'd190;
        end else if ((sqrt_input > 31'd38025) && (sqrt_input <= 31'd40000)) begin
                sqrt_output = 11'd195;
        end else if ((sqrt_input > 31'd40000) && (sqrt_input <= 31'd42025)) begin
                sqrt_output = 11'd200;
        end else if ((sqrt_input > 31'd42025) && (sqrt_input <= 31'd44100)) begin
                sqrt_output = 11'd205;
        end else if ((sqrt_input > 31'd44100) && (sqrt_input <= 31'd46225)) begin
                sqrt_output = 11'd210;
        end else if ((sqrt_input > 31'd46225) && (sqrt_input <= 31'd48400)) begin
                sqrt_output = 11'd215;
        end else if ((sqrt_input > 31'd48400) && (sqrt_input <= 31'd50625)) begin
                sqrt_output = 11'd220;
        end else if ((sqrt_input > 31'd50625) && (sqrt_input <= 31'd52900)) begin
                sqrt_output = 11'd225;
        end else if ((sqrt_input > 31'd52900) && (sqrt_input <= 31'd55225)) begin
                sqrt_output = 11'd230;
        end else if ((sqrt_input > 31'd55225) && (sqrt_input <= 31'd57600)) begin
                sqrt_output = 11'd235;
        end else if ((sqrt_input > 31'd57600) && (sqrt_input <= 31'd60025)) begin
                sqrt_output = 11'd240;
        end else if ((sqrt_input > 31'd60025) && (sqrt_input <= 31'd62500)) begin
                sqrt_output = 11'd245;
        end else if ((sqrt_input > 31'd62500) && (sqrt_input <= 31'd65025)) begin
                sqrt_output = 11'd250;
        end else if ((sqrt_input > 31'd65025) && (sqrt_input <= 31'd67600)) begin
                sqrt_output = 11'd255;
        end else if ((sqrt_input > 31'd67600) && (sqrt_input <= 31'd70225)) begin
                sqrt_output = 11'd260;
        end else if ((sqrt_input > 31'd70225) && (sqrt_input <= 31'd72900)) begin
                sqrt_output = 11'd265;
        end else if ((sqrt_input > 31'd72900) && (sqrt_input <= 31'd75625)) begin
                sqrt_output = 11'd270;
        end else if ((sqrt_input > 31'd75625) && (sqrt_input <= 31'd78400)) begin
                sqrt_output = 11'd275;
        end else if ((sqrt_input > 31'd78400) && (sqrt_input <= 31'd81225)) begin
                sqrt_output = 11'd280;
        end else if ((sqrt_input > 31'd81225) && (sqrt_input <= 31'd84100)) begin
                sqrt_output = 11'd285;
        end else if ((sqrt_input > 31'd84100) && (sqrt_input <= 31'd87025)) begin
                sqrt_output = 11'd290;
        end else if ((sqrt_input > 31'd87025) && (sqrt_input <= 31'd90000)) begin
                sqrt_output = 11'd295;
        end else if ((sqrt_input > 31'd90000) && (sqrt_input <= 31'd93025)) begin
                sqrt_output = 11'd300;
        end else if ((sqrt_input > 31'd93025) && (sqrt_input <= 31'd96100)) begin
                sqrt_output = 11'd305;
        end else if ((sqrt_input > 31'd96100) && (sqrt_input <= 31'd99225)) begin
                sqrt_output = 11'd310;
        end else if ((sqrt_input > 31'd99225) && (sqrt_input <= 31'd102400)) begin
                sqrt_output = 11'd315;
        end else if ((sqrt_input > 31'd102400) && (sqrt_input <= 31'd105625)) begin
                sqrt_output = 11'd320;
        end else if ((sqrt_input > 31'd105625) && (sqrt_input <= 31'd108900)) begin
                sqrt_output = 11'd325;
        end else if ((sqrt_input > 31'd108900) && (sqrt_input <= 31'd112225)) begin
                sqrt_output = 11'd330;
        end else if ((sqrt_input > 31'd112225) && (sqrt_input <= 31'd115600)) begin
                sqrt_output = 11'd335;
        end else if ((sqrt_input > 31'd115600) && (sqrt_input <= 31'd119025)) begin
                sqrt_output = 11'd340;
        end else if ((sqrt_input > 31'd119025) && (sqrt_input <= 31'd122500)) begin
                sqrt_output = 11'd345;
        end else if ((sqrt_input > 31'd122500) && (sqrt_input <= 31'd126025)) begin
                sqrt_output = 11'd350;
        end else if ((sqrt_input > 31'd126025) && (sqrt_input <= 31'd129600)) begin
                sqrt_output = 11'd355;
        end else if ((sqrt_input > 31'd129600) && (sqrt_input <= 31'd133225)) begin
                sqrt_output = 11'd360;
        end else if ((sqrt_input > 31'd133225) && (sqrt_input <= 31'd136900)) begin
                sqrt_output = 11'd365;
        end else if ((sqrt_input > 31'd136900) && (sqrt_input <= 31'd140625)) begin
                sqrt_output = 11'd370;
        end else if ((sqrt_input > 31'd140625) && (sqrt_input <= 31'd144400)) begin
                sqrt_output = 11'd375;
        end else if ((sqrt_input > 31'd144400) && (sqrt_input <= 31'd148225)) begin
                sqrt_output = 11'd380;
        end else if ((sqrt_input > 31'd148225) && (sqrt_input <= 31'd152100)) begin
                sqrt_output = 11'd385;
        end else if ((sqrt_input > 31'd152100) && (sqrt_input <= 31'd156025)) begin
                sqrt_output = 11'd390;
        end else if ((sqrt_input > 31'd156025) && (sqrt_input <= 31'd160000)) begin
                sqrt_output = 11'd395;
        end else if ((sqrt_input > 31'd160000) && (sqrt_input <= 31'd164025)) begin
                sqrt_output = 11'd400;
        end else if ((sqrt_input > 31'd164025) && (sqrt_input <= 31'd168100)) begin
                sqrt_output = 11'd405;
        end else if ((sqrt_input > 31'd168100) && (sqrt_input <= 31'd172225)) begin
                sqrt_output = 11'd410;
        end else if ((sqrt_input > 31'd172225) && (sqrt_input <= 31'd176400)) begin
                sqrt_output = 11'd415;
        end else if ((sqrt_input > 31'd176400) && (sqrt_input <= 31'd180625)) begin
                sqrt_output = 11'd420;
        end else if ((sqrt_input > 31'd180625) && (sqrt_input <= 31'd184900)) begin
                sqrt_output = 11'd425;
        end else if ((sqrt_input > 31'd184900) && (sqrt_input <= 31'd189225)) begin
                sqrt_output = 11'd430;
        end else if ((sqrt_input > 31'd189225) && (sqrt_input <= 31'd193600)) begin
                sqrt_output = 11'd435;
        end else if ((sqrt_input > 31'd193600) && (sqrt_input <= 31'd198025)) begin
                sqrt_output = 11'd440;
        end else if ((sqrt_input > 31'd198025) && (sqrt_input <= 31'd202500)) begin
                sqrt_output = 11'd445;
        end else if ((sqrt_input > 31'd202500) && (sqrt_input <= 31'd207025)) begin
                sqrt_output = 11'd450;
        end else if ((sqrt_input > 31'd207025) && (sqrt_input <= 31'd211600)) begin
                sqrt_output = 11'd455;
        end else if ((sqrt_input > 31'd211600) && (sqrt_input <= 31'd216225)) begin
                sqrt_output = 11'd460;
        end else if ((sqrt_input > 31'd216225) && (sqrt_input <= 31'd220900)) begin
                sqrt_output = 11'd465;
        end else if ((sqrt_input > 31'd220900) && (sqrt_input <= 31'd225625)) begin
                sqrt_output = 11'd470;
        end else if ((sqrt_input > 31'd225625) && (sqrt_input <= 31'd230400)) begin
                sqrt_output = 11'd475;
        end else if ((sqrt_input > 31'd230400) && (sqrt_input <= 31'd235225)) begin
                sqrt_output = 11'd480;
        end else if ((sqrt_input > 31'd235225) && (sqrt_input <= 31'd240100)) begin
                sqrt_output = 11'd485;
        end else if ((sqrt_input > 31'd240100) && (sqrt_input <= 31'd245025)) begin
                sqrt_output = 11'd490;
        end else if ((sqrt_input > 31'd245025) && (sqrt_input <= 31'd250000)) begin
                sqrt_output = 11'd495;
        end else if ((sqrt_input > 31'd250000) && (sqrt_input <= 31'd255025)) begin
                sqrt_output = 11'd500;
        end else if ((sqrt_input > 31'd255025) && (sqrt_input <= 31'd260100)) begin
                sqrt_output = 11'd505;
        end else if ((sqrt_input > 31'd260100) && (sqrt_input <= 31'd265225)) begin
                sqrt_output = 11'd510;
        end else if ((sqrt_input > 31'd265225) && (sqrt_input <= 31'd270400)) begin
                sqrt_output = 11'd515;
        end else if ((sqrt_input > 31'd270400) && (sqrt_input <= 31'd275625)) begin
                sqrt_output = 11'd520;
        end else if ((sqrt_input > 31'd275625) && (sqrt_input <= 31'd280900)) begin
                sqrt_output = 11'd525;
        end else if ((sqrt_input > 31'd280900) && (sqrt_input <= 31'd286225)) begin
                sqrt_output = 11'd530;
        end else if ((sqrt_input > 31'd286225) && (sqrt_input <= 31'd291600)) begin
                sqrt_output = 11'd535;
        end else if ((sqrt_input > 31'd291600) && (sqrt_input <= 31'd297025)) begin
                sqrt_output = 11'd540;
        end else if ((sqrt_input > 31'd297025) && (sqrt_input <= 31'd302500)) begin
                sqrt_output = 11'd545;
        end else if ((sqrt_input > 31'd302500) && (sqrt_input <= 31'd308025)) begin
                sqrt_output = 11'd550;
        end else if ((sqrt_input > 31'd308025) && (sqrt_input <= 31'd313600)) begin
                sqrt_output = 11'd555;
        end else if ((sqrt_input > 31'd313600) && (sqrt_input <= 31'd319225)) begin
                sqrt_output = 11'd560;
        end else if ((sqrt_input > 31'd319225) && (sqrt_input <= 31'd324900)) begin
                sqrt_output = 11'd565;
        end else if ((sqrt_input > 31'd324900) && (sqrt_input <= 31'd330625)) begin
                sqrt_output = 11'd570;
        end else if ((sqrt_input > 31'd330625) && (sqrt_input <= 31'd336400)) begin
                sqrt_output = 11'd575;
        end else if ((sqrt_input > 31'd336400) && (sqrt_input <= 31'd342225)) begin
                sqrt_output = 11'd580;
        end else if ((sqrt_input > 31'd342225) && (sqrt_input <= 31'd348100)) begin
                sqrt_output = 11'd585;
        end else if ((sqrt_input > 31'd348100) && (sqrt_input <= 31'd354025)) begin
                sqrt_output = 11'd590;
        end else if ((sqrt_input > 31'd354025) && (sqrt_input <= 31'd360000)) begin
                sqrt_output = 11'd595;
        end else if ((sqrt_input > 31'd360000) && (sqrt_input <= 31'd366025)) begin
                sqrt_output = 11'd600;
        end else if ((sqrt_input > 31'd366025) && (sqrt_input <= 31'd372100)) begin
                sqrt_output = 11'd605;
        end else if ((sqrt_input > 31'd372100) && (sqrt_input <= 31'd378225)) begin
                sqrt_output = 11'd610;
        end else if ((sqrt_input > 31'd378225) && (sqrt_input <= 31'd384400)) begin
                sqrt_output = 11'd615;
        end else if ((sqrt_input > 31'd384400) && (sqrt_input <= 31'd390625)) begin
                sqrt_output = 11'd620;
        end else if ((sqrt_input > 31'd390625) && (sqrt_input <= 31'd396900)) begin
                sqrt_output = 11'd625;
        end else if ((sqrt_input > 31'd396900) && (sqrt_input <= 31'd403225)) begin
                sqrt_output = 11'd630;
        end else if ((sqrt_input > 31'd403225) && (sqrt_input <= 31'd409600)) begin
                sqrt_output = 11'd635;
        end else if ((sqrt_input > 31'd409600) && (sqrt_input <= 31'd416025)) begin
                sqrt_output = 11'd640;
        end else if ((sqrt_input > 31'd416025) && (sqrt_input <= 31'd422500)) begin
                sqrt_output = 11'd645;
        end else if ((sqrt_input > 31'd422500) && (sqrt_input <= 31'd429025)) begin
                sqrt_output = 11'd650;
        end else if ((sqrt_input > 31'd429025) && (sqrt_input <= 31'd435600)) begin
                sqrt_output = 11'd655;
        end else if ((sqrt_input > 31'd435600) && (sqrt_input <= 31'd442225)) begin
                sqrt_output = 11'd660;
        end else if ((sqrt_input > 31'd442225) && (sqrt_input <= 31'd448900)) begin
                sqrt_output = 11'd665;
        end else if ((sqrt_input > 31'd448900) && (sqrt_input <= 31'd455625)) begin
                sqrt_output = 11'd670;
        end else if ((sqrt_input > 31'd455625) && (sqrt_input <= 31'd462400)) begin
                sqrt_output = 11'd675;
        end else if ((sqrt_input > 31'd462400) && (sqrt_input <= 31'd469225)) begin
                sqrt_output = 11'd680;
        end else if ((sqrt_input > 31'd469225) && (sqrt_input <= 31'd476100)) begin
                sqrt_output = 11'd685;
        end else if ((sqrt_input > 31'd476100) && (sqrt_input <= 31'd483025)) begin
                sqrt_output = 11'd690;
        end else if ((sqrt_input > 31'd483025) && (sqrt_input <= 31'd490000)) begin
                sqrt_output = 11'd695;
        end else if ((sqrt_input > 31'd490000) && (sqrt_input <= 31'd497025)) begin
                sqrt_output = 11'd700;
        end else if ((sqrt_input > 31'd497025) && (sqrt_input <= 31'd504100)) begin
                sqrt_output = 11'd705;
        end else if ((sqrt_input > 31'd504100) && (sqrt_input <= 31'd511225)) begin
                sqrt_output = 11'd710;
        end else if ((sqrt_input > 31'd511225) && (sqrt_input <= 31'd518400)) begin
                sqrt_output = 11'd715;
        end else if ((sqrt_input > 31'd518400) && (sqrt_input <= 31'd525625)) begin
                sqrt_output = 11'd720;
        end else if ((sqrt_input > 31'd525625) && (sqrt_input <= 31'd532900)) begin
                sqrt_output = 11'd725;
        end else if ((sqrt_input > 31'd532900) && (sqrt_input <= 31'd540225)) begin
                sqrt_output = 11'd730;
        end else if ((sqrt_input > 31'd540225) && (sqrt_input <= 31'd547600)) begin
                sqrt_output = 11'd735;
        end else if ((sqrt_input > 31'd547600) && (sqrt_input <= 31'd555025)) begin
                sqrt_output = 11'd740;
        end else if ((sqrt_input > 31'd555025) && (sqrt_input <= 31'd562500)) begin
                sqrt_output = 11'd745;
        end else if ((sqrt_input > 31'd562500) && (sqrt_input <= 31'd570025)) begin
                sqrt_output = 11'd750;
        end else if ((sqrt_input > 31'd570025) && (sqrt_input <= 31'd577600)) begin
                sqrt_output = 11'd755;
        end else if ((sqrt_input > 31'd577600) && (sqrt_input <= 31'd585225)) begin
                sqrt_output = 11'd760;
        end else if ((sqrt_input > 31'd585225) && (sqrt_input <= 31'd592900)) begin
                sqrt_output = 11'd765;
        end else if ((sqrt_input > 31'd592900) && (sqrt_input <= 31'd600625)) begin
                sqrt_output = 11'd770;
        end else if ((sqrt_input > 31'd600625) && (sqrt_input <= 31'd608400)) begin
                sqrt_output = 11'd775;
        end else if ((sqrt_input > 31'd608400) && (sqrt_input <= 31'd616225)) begin
                sqrt_output = 11'd780;
        end else if ((sqrt_input > 31'd616225) && (sqrt_input <= 31'd624100)) begin
                sqrt_output = 11'd785;
        end else if ((sqrt_input > 31'd624100) && (sqrt_input <= 31'd632025)) begin
                sqrt_output = 11'd790;
        end else if ((sqrt_input > 31'd632025) && (sqrt_input <= 31'd640000)) begin
                sqrt_output = 11'd795;
        end else if ((sqrt_input > 31'd640000) && (sqrt_input <= 31'd648025)) begin
                sqrt_output = 11'd800;
        end else if ((sqrt_input > 31'd648025) && (sqrt_input <= 31'd656100)) begin
                sqrt_output = 11'd805;
        end else if ((sqrt_input > 31'd656100) && (sqrt_input <= 31'd664225)) begin
                sqrt_output = 11'd810;
        end else if ((sqrt_input > 31'd664225) && (sqrt_input <= 31'd672400)) begin
                sqrt_output = 11'd815;
        end else if ((sqrt_input > 31'd672400) && (sqrt_input <= 31'd680625)) begin
                sqrt_output = 11'd820;
        end else if ((sqrt_input > 31'd680625) && (sqrt_input <= 31'd688900)) begin
                sqrt_output = 11'd825;
        end else if ((sqrt_input > 31'd688900) && (sqrt_input <= 31'd697225)) begin
                sqrt_output = 11'd830;
        end else if ((sqrt_input > 31'd697225) && (sqrt_input <= 31'd705600)) begin
                sqrt_output = 11'd835;
        end else if ((sqrt_input > 31'd705600) && (sqrt_input <= 31'd714025)) begin
                sqrt_output = 11'd840;
        end else if ((sqrt_input > 31'd714025) && (sqrt_input <= 31'd722500)) begin
                sqrt_output = 11'd845;
        end else if ((sqrt_input > 31'd722500) && (sqrt_input <= 31'd731025)) begin
                sqrt_output = 11'd850;
        end else if ((sqrt_input > 31'd731025) && (sqrt_input <= 31'd739600)) begin
                sqrt_output = 11'd855;
        end else if ((sqrt_input > 31'd739600) && (sqrt_input <= 31'd748225)) begin
                sqrt_output = 11'd860;
        end else if ((sqrt_input > 31'd748225) && (sqrt_input <= 31'd756900)) begin
                sqrt_output = 11'd865;
        end else if ((sqrt_input > 31'd756900) && (sqrt_input <= 31'd765625)) begin
                sqrt_output = 11'd870;
        end else if ((sqrt_input > 31'd765625) && (sqrt_input <= 31'd774400)) begin
                sqrt_output = 11'd875;
        end else if ((sqrt_input > 31'd774400) && (sqrt_input <= 31'd783225)) begin
                sqrt_output = 11'd880;
        end else if ((sqrt_input > 31'd783225) && (sqrt_input <= 31'd792100)) begin
                sqrt_output = 11'd885;
        end else if ((sqrt_input > 31'd792100) && (sqrt_input <= 31'd801025)) begin
                sqrt_output = 11'd890;
        end else if ((sqrt_input > 31'd801025) && (sqrt_input <= 31'd810000)) begin
                sqrt_output = 11'd895;
        end else if ((sqrt_input > 31'd810000) && (sqrt_input <= 31'd819025)) begin
                sqrt_output = 11'd900;
        end else if ((sqrt_input > 31'd819025) && (sqrt_input <= 31'd828100)) begin
                sqrt_output = 11'd905;
        end else if ((sqrt_input > 31'd828100) && (sqrt_input <= 31'd837225)) begin
                sqrt_output = 11'd910;
        end else if ((sqrt_input > 31'd837225) && (sqrt_input <= 31'd846400)) begin
                sqrt_output = 11'd915;
        end else if ((sqrt_input > 31'd846400) && (sqrt_input <= 31'd855625)) begin
                sqrt_output = 11'd920;
        end else if ((sqrt_input > 31'd855625) && (sqrt_input <= 31'd864900)) begin
                sqrt_output = 11'd925;
        end else if ((sqrt_input > 31'd864900) && (sqrt_input <= 31'd874225)) begin
                sqrt_output = 11'd930;
        end else if ((sqrt_input > 31'd874225) && (sqrt_input <= 31'd883600)) begin
                sqrt_output = 11'd935;
        end else if ((sqrt_input > 31'd883600) && (sqrt_input <= 31'd893025)) begin
                sqrt_output = 11'd940;
        end else if ((sqrt_input > 31'd893025) && (sqrt_input <= 31'd902500)) begin
                sqrt_output = 11'd945;
        end else if ((sqrt_input > 31'd902500) && (sqrt_input <= 31'd912025)) begin
                sqrt_output = 11'd950;
        end else if ((sqrt_input > 31'd912025) && (sqrt_input <= 31'd921600)) begin
                sqrt_output = 11'd955;
        end else if ((sqrt_input > 31'd921600) && (sqrt_input <= 31'd931225)) begin
                sqrt_output = 11'd960;
        end else if ((sqrt_input > 31'd931225) && (sqrt_input <= 31'd940900)) begin
                sqrt_output = 11'd965;
        end else if ((sqrt_input > 31'd940900) && (sqrt_input <= 31'd950625)) begin
                sqrt_output = 11'd970;
        end else if ((sqrt_input > 31'd950625) && (sqrt_input <= 31'd960400)) begin
                sqrt_output = 11'd975;
        end else if ((sqrt_input > 31'd960400) && (sqrt_input <= 31'd970225)) begin
                sqrt_output = 11'd980;
        end else if ((sqrt_input > 31'd970225) && (sqrt_input <= 31'd980100)) begin
                sqrt_output = 11'd985;
        end else if ((sqrt_input > 31'd980100) && (sqrt_input <= 31'd990025)) begin
                sqrt_output = 11'd990;
        end else if ((sqrt_input > 31'd990025) && (sqrt_input <= 31'd1000000)) begin
                sqrt_output = 11'd995;
        end else if ((sqrt_input > 31'd1000000) && (sqrt_input <= 31'd1010025)) begin
                sqrt_output = 11'd1000;
        end else if ((sqrt_input > 31'd1010025) && (sqrt_input <= 31'd1020100)) begin
                sqrt_output = 11'd1005;
        end else if ((sqrt_input > 31'd1020100) && (sqrt_input <= 31'd1030225)) begin
                sqrt_output = 11'd1010;
        end else begin
            sqrt_output = 11'd0;
        end
    end
endmodule
