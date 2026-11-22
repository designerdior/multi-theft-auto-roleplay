//-- Shader na usuwanie/zmienianie brudu na pojazdach

texture Grunge;

technique setgrunge
{
	pass P0
	{
		Texture[0] = Grunge;
	}
}