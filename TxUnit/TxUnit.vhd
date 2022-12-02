library IEEE;
use IEEE.std_logic_1164.all;

entity TxUnit is
  port (
    clk, reset : in std_logic;
    enable : in std_logic;
    ld : in std_logic;
    txd : out std_logic;
    regE : out std_logic;
    bufE : out std_logic;
    data : in std_logic_vector(7 downto 0));
end TxUnit;

architecture behavorial of TxUnit is

  --Declaration des etats
  type t_etat is (REPOS, REMPLISSAGE_ENVOI, EMISSION);
  signal etat : t_etat;
  
  signal bufferT : std_logic_vector(7 downto 0);
  signal registreT : std_logic_vector(7 downto 0);
  signal bitP : std_logic;
  signal cpt : integer;

begin

  process(clk,reset)
  begin
    if reset = '1' then
      cpt <= 10;
      txd <= '1';
      regE <= '1';
      bufE <= '1';
    elsif rising_edge(clk) then
      case etat is
        when REPOS =>
          if ld = '1' then
            bufferT <= data;
            bufE <= '0';
            etat <= REMPLISSAGE_ENVOI;
          end if;
        when REMPLISSAGE_ENVOI =>
          registreT <= bufferT;
          regE <= '0';
          bufE <= '1';
          etat <= EMISSION;        
        when EMISSION =>
          if enable = '1' then
            case cpt is
              when 9 =>
              --envoi du bit du Debut de Trame : txD <= '0';
                txd <= '0';
                cpt <= cpt - 1;
              when 1 =>
              --envoi du bit de Partie
                regE <= '1'; --on libere le registre car on a émit tout le registre
                txd <= bitP;
                cpt <= 8;
              when 0 =>
              --envoi du bit de Fin de Trame : txD = 1
                txd <= '1';
                cpt <= cpt - 1;
                etat <= REPOS;
              when others =>
              --envoi des bits suivants
                txd <= registreT(cpt-2);
                bitP <= bitP xor registreT(cpt-2);
                cpt <= cpt-1;
            end case;
          end if;
      end case;
    end if;
  end process;

end behavorial;
